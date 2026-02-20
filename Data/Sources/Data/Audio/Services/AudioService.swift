import AVFoundation
import Business
import Foundation
import MediaPlayer

final public class AudioService: AudioServiceContract, @unchecked Sendable {
    
    // Private State
    private let session: AVAudioSession = .sharedInstance()
    private var commandCenter = RemoteCommandService()
    private var audioInfo = AudioInfoService()
    private var player: AVPlayer? = nil
    private var timeObserver: Any? = nil
    private var endObserver: Any? = nil
    private var interruptionHandler: Any? = nil
    private var lock = NSLock()
    
    public var delegate: AudioServiceDelegateContract?
    
    public init() { }
    
    public func start(_ url: URL, token: String) throws {
        
        // Create AVPlayer item with auth header.
        let headers = ["Authorization": "Bearer \(token)"]
        let item = AVPlayerItem(
            asset: AVURLAsset(
                url: url,
                options: ["AVURLAssetHTTPHeaderFieldsKey": headers]
            )
        )
        
        try lock.withLock {
            // Remove observer watching for end of audio.
            disableDidPlayToEnd()
            
            // Create or update current player.
            if let player {
                player.replaceCurrentItem(with: item)
            } else {
                player = AVPlayer(playerItem: item)
            }
            
            try activateAudioSession()
            activateInterruptionHandling()
            enableDurationUpdates()
            enableDidPlayToEnd()
        }
    }
    
    public func setMedia(with data: AudioData) {
        lock.lock()
        defer { lock.unlock() }
        
        audioInfo.update(with: data)
        
        commandCenter.enable(.play) { [weak self] _ in
            self?.play()
            return .success
        }
        
        commandCenter.enable(.pause) { [weak self] _ in
            self?.pause()
            return .success
        }
        
        commandCenter.enable(.skipForward) { [weak self] _ in
            guard let self, let player = lock.withLock({ self.player }) else { return .noSuchContent }
            
            player.seek(
                to: player.currentTime() + CMTime(seconds: 15, preferredTimescale: 1),
                toleranceBefore: CMTime(seconds: 1, preferredTimescale: 1),
                toleranceAfter: CMTime(seconds: 1, preferredTimescale: 1),
                completionHandler: { [weak self] _ in
                    guard let self else { return }
                    let seconds = Int(player.currentTime().seconds)
                    delegate?.playerDidUpdateTimePlayed(seconds)
                    audioInfo.update(duration: seconds, rate: player.rate)
                }
            )
            
            return .success
        }
        
        commandCenter.enable(.skipBackward) { [weak self] _ in
            guard let self, let player = lock.withLock({ self.player }) else { return .noSuchContent }
            
            player.seek(
                to: player.currentTime() - CMTime(seconds: 15, preferredTimescale: 1),
                toleranceBefore: CMTime(seconds: 1, preferredTimescale: 1),
                toleranceAfter: CMTime(seconds: 1, preferredTimescale: 1),
                completionHandler: { [weak self] _ in
                    guard let self else { return }
                    let seconds = Int(player.currentTime().seconds)
                    delegate?.playerDidUpdateTimePlayed(seconds)
                    audioInfo.update(duration: seconds, rate: player.rate)
                }
            )
            
            return .success
        }
    }
    
    public func play() {
        lock.withLock {
            guard let player else { return }
        
            player.play()
            delegate?.playerDidResume()
            
            let seconds = Int(player.currentTime().seconds)
            audioInfo.update(duration: seconds, rate: player.rate)
        }
    }
    
    public func pause() {
        lock.withLock {
            guard let player else { return }

            player.pause()
            delegate?.playerDidPause()
            
            let seconds = Int(player.currentTime().seconds)
            audioInfo.update(duration: seconds, rate: player.rate)
        }
    }
    
    public func stop(notify: Bool) {
        lock.withLock {
            guard let player else { return }

            player.pause()
            player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
            audioInfo.update(duration: 0, rate: 0)
            
            if notify {
                delegate?.playerDidStop()
            }
        }
    }
    
    public func skipForward() async {
        guard let player = lock.withLock({ self.player }) else { return }
        
        await player.seek(
            to: player.currentTime() + CMTime(seconds: 15, preferredTimescale: 1),
            toleranceBefore: CMTime(seconds: 1, preferredTimescale: 1),
            toleranceAfter: CMTime(seconds: 1, preferredTimescale: 1)
        )
        
        lock.withLock {
            let seconds = Int(player.currentTime().seconds)
            delegate?.playerDidUpdateTimePlayed(seconds)
            audioInfo.update(duration: seconds, rate: player.rate)
        }
    }
    
    public func skipBackward() async {
        guard let player = lock.withLock({ self.player }) else { return }
        
        await player.seek(
            to: player.currentTime() - CMTime(seconds: 15, preferredTimescale: 1),
            toleranceBefore: CMTime(seconds: 1, preferredTimescale: 1),
            toleranceAfter: CMTime(seconds: 1, preferredTimescale: 1)
        )
        
        lock.withLock {
            let seconds = Int(player.currentTime().seconds)
            delegate?.playerDidUpdateTimePlayed(seconds)
            audioInfo.update(duration: seconds, rate: player.rate)
        }
    }
    
    public func seek(to time: Int) async {
        guard let player = lock.withLock({ self.player }) else { return }
        
        await player.seek(
            to: CMTime(value: Int64(time), timescale: 1),
            toleranceBefore: CMTime(seconds: 1, preferredTimescale: 1),
            toleranceAfter: CMTime(seconds: 1, preferredTimescale: 1)
        )
        
        lock.withLock {
            let seconds = Int(player.currentTime().seconds)
            delegate?.playerDidUpdateTimePlayed(seconds)
            audioInfo.update(duration: seconds, rate: player.rate)
        }
    }
    
    public func awaitReadyToPlay() async {
        guard let player = lock.withLock { self.player }, player.status != .readyToPlay else { return }
        
        await withCheckedContinuation { cont in
            var observation: NSKeyValueObservation!
            observation = player.observe(\.status) { player, _ in
                if player.status == .readyToPlay {
                    observation.invalidate()
                    cont.resume()
                }
            }
        }
    }
}

// MARK: - Audio Session Setup
extension AudioService {
    private func activateAudioSession() throws {
        try session.setCategory(.playback, mode: .spokenAudio)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    private func activateInterruptionHandling() {
        // Prevent creating duplicates
        guard interruptionHandler == nil else { return }
        
        interruptionHandler = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: session,
            queue: .main,
            using: { [weak self] notification in
                guard let userInfo = notification.userInfo,
                      let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                      let type = AVAudioSession.InterruptionType(rawValue: typeValue)
                else { return }
                
                switch type {
                    case .began: self?.pause()
                    case .ended:
                        guard let optionsValues = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt
                        else { return }
                        
                        let options = AVAudioSession.InterruptionOptions(rawValue: optionsValues)
                        if options.contains(.shouldResume) {
                            self?.play()
                        }
                    default: break
                }
            }
        )
    }
    
    private func enableDurationUpdates() {
        // Prevent creating duplicates
        guard timeObserver == nil else { return }
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 1),
            queue: .main,
            using: { [weak self] time in
                self?.delegate?.playerDidUpdateTimePlayed(Int(time.seconds))
            }
        )
    }
    
    private func enableDidPlayToEnd() {
        guard let item = player?.currentItem else { return }
        endObserver = NotificationCenter.default.addObserver(
            forName: AVPlayerItem.didPlayToEndTimeNotification,
            object: item,
            queue: .main,
            using: { [weak self] notification in
                guard let delegate = self?.delegate,
                      let player = self?.player
                else { return }
                
                delegate.playerDidFinish(Int(player.currentTime().seconds))
                self?.endObserver = nil
            }
        )
    }
    
    private func disableDidPlayToEnd() {
        guard let endObserver, let item = player?.currentItem
        else { endObserver = nil; return }
        
        NotificationCenter.default.removeObserver(
            endObserver,
            name: AVPlayerItem.didPlayToEndTimeNotification,
            object: item
        )
    }
}
