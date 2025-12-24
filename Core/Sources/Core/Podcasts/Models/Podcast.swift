import Foundation

public struct Podcast: Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let link: URL?
    public let language: String
    public let imageURL: URL?
    public let description: String
    
    public let episodes: [Episode]?
    
    public init(id: UUID, title: String, link: URL?, language: String, imageURL: URL?, description: String, episodes: [Episode]? = nil) {
        self.id = id
        self.title = title
        self.link = link
        self.language = language
        self.imageURL = imageURL
        self.description = description
        
        self.episodes = episodes
    }
}
