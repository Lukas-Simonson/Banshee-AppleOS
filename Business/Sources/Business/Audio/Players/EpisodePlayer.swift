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
            if let savedQueue = localQueue.get() {
                do {
                    try await enqueue(savedQueue, startPlaying: false)
                } catch let error as EpisodePlayerError {
                    await playerStateFlow.emit(.error(error))
                }
            }
        }
    }
    
    // Player Management
    public func enqueue(_ newQueue: AudioQueue, startPlaying: Bool = true) async throws(EpisodePlayerError) {
            logger.info("Filling queue with \(newQueue.count) episodes.")
            self.queue = newQueue

            // Reset sync tracking for new episode
            lastSyncTime = nil

            guard let server = await serverProvider.server,
                  let token = await serverProvider.token,
                  let url = URL(string: "\(server)/api/episodes/\(newQueue.current)/audio")
            else { throw EpisodePlayerError.userNotAuthenticated }
            
            await playerStateFlow.emit(.loading(size: newQueue.count))
            
            async let fetchEpisode = remote.episode(with: newQueue.current, baseURL: server, token: token.token)
            async let loadAudio = audio.start(url, token: token.token)
            
            do {
                let (episode, _) = try await (fetchEpisode, loadAudio)
                let newState = AudioPlayerState(
                    title: episode.title,
                    imageURL: episode.imageURL ?? newQueue.podcastImageURL,
                    current: episode.progress?.duration ?? 0,
                    duration: episode.duration ?? 1,
                    queueSize: newQueue.count,
                    queuePosition: 1,
                    mode: startPlaying ? .playing : .paused
                )
                
                if let progress = episode.progress {
                    await audio.seek(to: progress.duration)
                }
                
                // Persist queue to local storage.
                localQueue.save(newQueue)
                
                await playerStateFlow.emit(newState)
                await audio.setMedia(with: AudioData(image: nil, title: episode.title))
                
                if startPlaying {
                    await audio.play()
                }
            } catch {
                logger.error("Error playing episode", for: error)

                if let e = error as? CoreError {
                    await playerStateFlow.emit(.error(e))
                } else {
                    await playerStateFlow.emit(.error(EpisodePlayerError.unexpectedError))
                    logger.error("Received a non-CoreError when playing audio", for: error)
                }
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
                isCompleted: false,
                duration: currentTime
            )
            
            async let updateRemote = remote.updateProgress(
                episodeId: currentEpisodeId,
                baseURL: server,
                token: token.token,
                isCompleted: false,
                duration: currentTime
            )
            
            try await (updateLocal, updateRemote)
            
            lastSyncTime = .now
            logger.info("Successfully synced progress: \(currentTime)s for episode \(currentEpisodeId)")
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
    
    nonisolated public func playerDidFinish() {
        Task {
            // Sync final progress with isCompleted = true
            guard let queue = await self.queue,
                  let state = await playerState
            else { return }

            await syncProgressNow(currentTime: state.duration, isCompleted: true)

            // TODO: Go to next item in queue.
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
    
    public func next() async { fatalError() }
    
    public func prev() async { fatalError() }
    
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
            imageURL: imageURL,
            current: current ?? self.current,
            duration: duration ?? self.duration,
            queueSize: queueSize,
            queuePosition: queuePosition,
            mode: mode ?? self.mode
        )
    }
}
