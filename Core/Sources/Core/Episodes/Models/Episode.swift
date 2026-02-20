import Foundation

public struct Episode: Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let pubDate: Date
    public let description: String
    public let imageURL: URL?
    public let season: String?
    public let episode: Int?
    public let duration: Int?
    public let progress: AudioProgress?
    
    public init(
        id: UUID,
        title: String,
        pubDate: Date,
        description: String,
        imageURL: URL?,
        season: String?,
        episode: Int?,
        duration: Int?,
        progress: AudioProgress?
    ) {
        self.id = id
        self.title = title
        self.pubDate = pubDate
        self.description = description
        self.imageURL = imageURL
        self.season = season
        self.episode = episode
        self.duration = duration
        self.progress = progress
    }
}

extension Episode {
    public enum Order: Codable, Sendable {
        case title(asc: Bool = true)
        case date(asc: Bool = true)
        case seasonEpisode(asc: Bool = true)
    }
}
