import Foundation

public struct AudioPlayerState: Sendable {
    public let title: String
    public let author: String?
    public let imageURL: URL?
    
    public let current: Int
    public let duration: Int
    
    public let queueSize: Int
    public let queuePosition: Int
    
    public var hasNext: Bool { queuePosition < queueSize }
    public var hasPrev: Bool { queuePosition > 1 } // 1 to offset 0 indexed
    
    public let mode: Mode
    
    public init(
        title: String,
        author: String?,
        imageURL: URL?,
        current: Int,
        duration: Int,
        queueSize: Int,
        queuePosition: Int,
        mode: Mode
    ) {
        self.title = title
        self.author = author
        self.imageURL = imageURL
        self.current = current
        self.duration = duration
        self.queueSize = queueSize
        self.queuePosition = queuePosition
        self.mode = mode
    }
}

extension AudioPlayerState {
    public enum Mode: Sendable, Equatable {
        case playing
        case paused
        case loading
        case error(CoreError)

        public static func ==(lhs: Mode, rhs: Mode) -> Bool {
            switch (lhs, rhs) {
                case (.playing, .playing): true
                case (.paused, .paused): true
                case (.loading, .loading): true
                case (.error(let lhs), .error(let rhs)): lhs.errorCode == rhs.errorCode
                default: false
            }
        }
    }
}

// MARK: - Defaults
public extension AudioPlayerState {
    static func loading(size: Int, position: Int = 0) -> AudioPlayerState {
        AudioPlayerState(
            title: "",
            author: nil,
            imageURL: nil,
            current: 0,
            duration: 0,
            queueSize: size,
            queuePosition: position,
            mode: .loading
        )
    }
    
    static func error(_ error: CoreError) -> AudioPlayerState {
        AudioPlayerState(
            title: "",
            author: nil,
            imageURL: nil,
            current: 0,
            duration: 0,
            queueSize: 0,
            queuePosition: 0,
            mode: .error(error)
        )
    }
}
