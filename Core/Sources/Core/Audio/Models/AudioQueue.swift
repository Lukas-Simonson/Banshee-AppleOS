import Foundation

public struct AudioQueue: Sendable {
    public let queue: [UUID]
    public let podcastImageURL: URL?
    
    public var position: Int = 0
    
    public var current: UUID { queue[position] }
    public var count: Int { queue.count }
    public var isEmpty: Bool { queue.isEmpty }
    
    public init(queue: [UUID], podcastImageURL: URL?, position: Int = 0) {
        self.queue = queue
        self.podcastImageURL = podcastImageURL
        self.position = position
    }
}
