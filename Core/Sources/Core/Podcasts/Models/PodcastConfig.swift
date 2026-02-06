import Foundation

public struct PodcastConfig: Sendable {
    public var title: String?
    public var imageURL: URL?
    public var description: String?
    public var podcastID: UUID
    
    public init(title: String?, imageURL: URL?, description: String?, podcastID: UUID) {
        self.title = title
        self.imageURL = imageURL
        self.description = description
        self.podcastID = podcastID
    }
}
