import MediaPlayer

struct RemoteCommandService {
    private let center: MPRemoteCommandCenter = .shared()
    private var targets: [Command: Any] = [:]
    
    mutating func enable(_ command: Command, handler: @escaping (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus) {
        let remote = command.remote(for: center)
        remote.isEnabled = true
        targets[command] = remote.addTarget(handler: handler)
    }
    
    mutating func disable(_ command: Command) {
        guard let target = targets.removeValue(forKey: command) else { return }
        let remote = command.remote(for: center)
        remote.isEnabled = false
        remote.removeTarget(target)
    }
    
    mutating func disableAll() {
        for (command, target) in targets {
            let remote = command.remote(for: center)
            remote.isEnabled = false
            remote.removeTarget(target)
        }
        targets = [:]
    }
    
    enum Command {
        case play
        case pause
        case skipForward
        case skipBackward
        
        func remote(for center: MPRemoteCommandCenter) -> MPRemoteCommand {
            switch self {
                case .play: center.playCommand
                case .pause: center.pauseCommand
                case .skipForward: center.skipForwardCommand
                case .skipBackward: center.skipBackwardCommand
            }
        }
    }
}
