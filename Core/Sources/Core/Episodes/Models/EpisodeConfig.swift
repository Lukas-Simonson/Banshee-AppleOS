import Foundation

public struct EpisodeConfig: Sendable {
    public var title: String?
    public var description: String?
    public var imageURL: URL?
    public var season: String?
    public var episode: Int?
    public var episodeID: UUID
    
    public init(title: String? = nil, description: String? = nil, imageURL: URL? = nil, season: String? = nil, episode: Int? = nil, episodeID: UUID) {
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.season = season
        self.episode = episode
        self.episodeID = episodeID
    }
}
