import Core
import Foundation
import Logging
import Overflow

public actor EpisodePlayer: EpisodePlayerContract {
    
    // Private State
    private let audio: AudioServiceContract
    private let logger: Logger
    private let serverProvider: ServerProviderContract
    private let remote: RemotePlayerDataSourceContract
    private let local: LocalPlayerDataSourceContract
    private let localQueue: LocalQueueDataSourceContract
    
    private let playerStateFlow = MutableStateFlow<AudioPlayerState?>(initial: nil)
    private var queue: AudioQueue?
    
    // Progress Sync State
    private var lastSyncTime: Date?
    private let syncInterval: TimeInterval = 30.0  // 30 seconds
    
    // Shared State
    public var playerState: AudioPlayerState? {
        get async { await playerStateFlow.value }
    }
    
    nonisolated public var playerStateStream: AsyncSequence<AudioPlayerState?, Never> {
        playerStateFlow
    }
    
    public init(
        audio: AudioServiceContract,
        logger: Logger,
        serverProvider: ServerProviderContract,
        remote: RemotePlayerDataSourceContract,
        local: LocalPlayerDataSourceContract,
        localQueue: LocalQueueDataSourceContract
    ) {
        self.audio = audio
        self.logger = logger
        self.serverProvider = serverProvider
        self.remote = remote
        self.local = local
        self.localQueue = localQueue
        
        self.audio.delegate = self
        
        Task {
            if let queue = localQueue.get() {
                do {
                    try await enqueue(queue, startPlaying: false)
                } catch let error as CoreError {
                    await playerStateFlow.emit(.error(error))
                }
            }
        }
    }
    
    // Player Management
    public func enqueue(_ newQueue: AudioQueue, startPlaying: Bool = true) async throws(CoreError) {
        logger.info("Filling queue with \(newQueue.count) episodes.")
        self.queue = newQueue
        
        guard let current = newQueue.current
        else { fatalError("Created an invalid queue with a position that is out of bounds.") }
        
        // Reset sync tracking for new episode
        lastSyncTime = nil
        
        guard let server = await serverProvider.server,
              let token = await serverProvider.token,
              let url = URL(string: "\(server)/api/episodes/\(current)/audio")
        else { throw CoreError.notAuthenticated(layer: .business, feature: .audio) }

        await playerStateFlow.emit(.loading(size: newQueue.count))
        
        async let fetchEpisode = remote.episode(with: current, baseURL: server, token: token.token)
        async let loadAudio = audio.start(url, token: token.token)
        
        do {
            let (episode, _) = try await (fetchEpisode, loadAudio)
            let newState = AudioPlayerState(
                title: episode.title,
                author: newQueue.podcastName,
                imageURL: episode.imageURL ?? newQueue.podcastImageURL,
                current: episode.progress?.watchTime ?? 0,
                duration: episode.duration ?? 1,
                queueSize: newQueue.count,
                queuePosition: newQueue.position + 1, // +1 to offset zero indexed
                mode: startPlaying ? .playing : .paused
            )

            if let progress = episode.progress {
                if progress.isCompleted {
                    await seek(to: 0) // Seek to start, and sync progress.
                } else {
                    await audio.seek(to: progress.watchTime)
                }
            }

            // Persist queue to local storage.
            localQueue.save(newQueue)

            await playerStateFlow.emit(newState)
            await audio.setMedia(with: AudioData(image: nil, title: episode.title, watchTime: episode.progress?.watchTime, totalDuration: episode.duration ?? 0))

            if startPlaying {
                await audio.play()
            }
        } catch let error as CoreError {
            await playerStateFlow.emit(.error(error))
        } catch {
            logger.error("Received an unexpected error when playing audio", for: error)
            await playerStateFlow.emit(.error(CoreError.unexpected(layer: .business, feature: .audio)))
        }
    }
    
    // MARK: - Progress Syncing
    
    private func syncProgressIfNeeded(currentTime: Int) async {
        // Check if enough time has elapsed since last sync
        let now = Date()
        if let lastSync = lastSyncTime {
            let timeSinceLastSync = now.timeIntervalSince(lastSync)
            guard timeSinceLastSync >= syncInterval else { return }
        }
        
        await syncProgressNow(currentTime: currentTime, isCompleted: false)
    }
    
    private func syncProgressNow(currentTime: Int, isCompleted: Bool) async {
        guard let queue = self.queue,
              let server = await serverProvider.server,
              let token = await serverProvider.token
        else { return }
        
        let currentEpisodeId = queue.queue[queue.position]
        
        do {
            async let updateLocal = local.updateProgress(
                episodeID: currentEpisodeId,
                isCompleted: isCompleted,
                watchTime: currentTime
            )
            
            async let updateRemote = remote.updateProgress(
                episodeId: currentEpisodeId,
                baseURL: server,
                token: token.token,
                isCompleted: isCompleted,
                watchTime: currentTime
            )
            
            try await (updateLocal, updateRemote)
            
            lastSyncTime = .now
            logger.info("Successfully synced progress: \(currentTime)s isCompleted: \(isCompleted) for episode \(currentEpisodeId)")
        } catch {
            logger.warning("Failed to sync progress", for: error)
        }
    }
}

// MARK: - Audio Player Delegate
extension EpisodePlayer: AudioServiceDelegateContract {
    nonisolated public func playerDidUpdateTimePlayed(_ time: Int) {
        Task {
            if let state = await self.playerState {
                await playerStateFlow.emit(state.copy(current: time))
                
                // Check if we should sync progress
                await syncProgressIfNeeded(currentTime: time)
            }
        }
    }
    
    nonisolated public func playerDidResume() {
        Task {
            if let state = await self.playerState {
                await playerStateFlow.emit(state.copy(mode: .playing))
            }
        }
    }
    
    nonisolated public func playerDidPause() {
        Task {
            if let state = await self.playerState {
                await playerStateFlow.emit(state.copy(mode: .paused))
            }
        }
    }
    
    nonisolated public func playerDidStop() {
        Task {
            if let state = await self.playerState {
                // Sync before stopping
                await syncProgressNow(currentTime: state.current, isCompleted: false)
                await playerStateFlow.emit(nil)
            }
        }
    }
    
    nonisolated public func playerDidFinish(_ time: Int) {
        Task {
            logger.info("Finished playing current item.")
            await syncProgressNow(currentTime: time, isCompleted: true)
            
            let queue = await self.queue
            if let queue, queue.hasNext {
                await next()
            } else {
                await playerStateFlow.emit(nil)
            }
        }
    }
    
    nonisolated public func playerDidEncounterError(_ error: Error?) {
        // TODO: Handle somehow
    }
}

// MARK: - Audio Passthrough Functions
extension EpisodePlayer {
    public func play() async { await audio.play() }
    
    public func pause() async { await audio.pause() }
    
    public func stop() async { await audio.stop() }
    
    public func next() async {
        do {
            guard let next = queue?.next() else { return }
            
            try await enqueue(
                next,
                startPlaying: true
            )
        } catch {
            await playerStateFlow.emit(.error(error))
        }
    }
    
    public func prev() async {
        do {
            guard let prev = queue?.prev() else { return }
            
            try await enqueue(
                prev,
                startPlaying: true
            )
        } catch {
            await playerStateFlow.emit(.error(error))
        }
    }
    
    public func skipForward() async { await audio.skipForward() }
    
    public func skipBackward() async { await audio.skipBackward() }
    
    public func seek(to seconds: Int) async {
        await audio.seek(to: seconds)
        await syncProgressNow(currentTime: seconds, isCompleted: false)
    }
}

extension AudioPlayerState {
    func copy(
        current: Int? = nil,
        duration: Int? = nil,
        mode: Mode? = nil
    ) -> AudioPlayerState {
        AudioPlayerState(
            title: title,
            author: author,
            imageURL: imageURL,
            current: current ?? self.current,
            duration: duration ?? self.duration,
            queueSize: queueSize,
            queuePosition: queuePosition,
            mode: mode ?? self.mode
        )
    }
}
