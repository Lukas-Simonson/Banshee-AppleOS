import Foundation

public struct AudioPlayerState: Sendable {
    public let title: String
    public let imageURL: URL?
    
    public let current: Int
    public let duration: Int
    
    public let queueSize: Int
    public let queuePosition: Int
    
    public let mode: Mode
    
    public init(
        title: String,
        imageURL: URL?,
        current: Int,
        duration: Int,
        queueSize: Int,
        queuePosition: Int,
        mode: Mode
    ) {
        self.title = title
        self.imageURL = imageURL
        self.current = current
        self.duration = duration
        self.queueSize = queueSize
        self.queuePosition = queuePosition
        self.mode = mode
    }
}

extension AudioPlayerState {
    public enum Mode: Sendable {
        case playing
        case paused
        case loading
        case error(Error)
    }
}

// MARK: - Defaults
public extension AudioPlayerState {
    static func loading(size: Int, position: Int = 0) -> AudioPlayerState {
        AudioPlayerState(
            title: "",
            imageURL: nil,
            current: 0,
            duration: 0,
            queueSize: size,
            queuePosition: position,
            mode: .loading
        )
    }
}
