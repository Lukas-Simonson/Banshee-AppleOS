import Foundation

public struct AudioQueue: Sendable {
    public let queue: [UUID]
    public let podcastName: String
    public let podcastImageURL: URL?
    public let position: Int
    
    public var hasPrev: Bool { position > 0 }
    public var hasNext: Bool { (position + 1) < count }
    
    public var current: UUID? {
        guard queue.indices.contains(position)
        else { return nil }
        
        return queue[position]
    }
    public var count: Int { queue.count }
    public var isEmpty: Bool { queue.isEmpty }
    
    public init(queue: [UUID], podcastName: String, podcastImageURL: URL?, position: Int = 0) {
        self.queue = queue
        self.podcastName = podcastName
        self.podcastImageURL = podcastImageURL
        self.position = position
    }
    
    public func prev() -> AudioQueue? {
        guard hasPrev else { return nil }
        
        return AudioQueue(
            queue: queue,
            podcastName: podcastName,
            podcastImageURL: podcastImageURL,
            position: position - 1
        )
    }
    
    public func next() -> AudioQueue? {
        guard hasNext else { return nil }
        
        return AudioQueue(
            queue: queue,
            podcastName: podcastName,
            podcastImageURL: podcastImageURL,
            position: position + 1
        )
    }
}
