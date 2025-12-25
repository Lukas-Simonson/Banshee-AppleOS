import AVFoundation
import Business
import Foundation

final public class AudioService: NSObject, AudioServiceContract, @unchecked Sendable {

    // Private State
    private var session: AVAudioSession = .sharedInstance()
    private var player: AVPlayer? = nil
    private var timeObserver: Any? = nil
    private var interruptionHandler: Any? = nil
    private var lock = NSLock()
    
    public var delegate: AudioServiceDelegateContract?
    
    public func start(_ url: URL, token: String) throws {
        
        // Create AVPlayer item with auth header.
        let headers = ["Authorization": "Bearer \(token)"]
        let item = AVPlayerItem(
            asset: AVURLAsset(
                url: url,
                options: ["AVURLAssetHTTPHeaderFieldsKey": headers]
            )
        )
    
        lock.withLock {
            // Create or update current player.
            if let player {
                player.replaceCurrentItem(with: item)
            } else {
                player = AVPlayer(playerItem: item)
            }
        }
        
        try activateAudioSession()
        activateInterruptionHandling()
        enableDurationUpdates()
    }
    
    public func setMedia(with data: AudioData) {
        
    }
    
    public func play() {
        if let player {
            player.play()
            delegate?.playerDidResume()
        }
    }
    
    public func pause() {
        if let player {
            player.pause()
            delegate?.playerDidPause()
        }
    }
    
    public func stop() {
        if let player {
            lock.withLock {
                player.pause()
                player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
                delegate?.playerDidStop()
            }
        }
    }
    
    public func skipForward() async {
        guard let player else { return }
        
        await player.seek(
            to: player.currentTime() + CMTime(seconds: 15, preferredTimescale: 1),
            toleranceBefore: CMTime(seconds: 1, preferredTimescale: 1),
            toleranceAfter: CMTime(seconds: 1, preferredTimescale: 1)
        )
        
        delegate?.playerDidUpdateTimePlayed(Int(player.currentTime().seconds))
    }
    
    public func skipBackward() async {
        guard let player else { return }
        
        await player.seek(
            to: player.currentTime() - CMTime(seconds: 15, preferredTimescale: 1),
            toleranceBefore: CMTime(seconds: 1, preferredTimescale: 1),
            toleranceAfter: CMTime(seconds: 1, preferredTimescale: 1)
        )
        
        delegate?.playerDidUpdateTimePlayed(Int(player.currentTime().seconds))
    }
}

// TODO: Implement Lockscreen Player

// MARK: - Player Delegate
extension AudioService: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.playerDidFinish()
    }
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        delegate?.playerDidEncounterError(error)
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
}
