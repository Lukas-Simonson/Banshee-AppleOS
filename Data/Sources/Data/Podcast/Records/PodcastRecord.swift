import Business
import Core
import Foundation
import GRDB

/// GRDB Record for persisting Podcast data.
struct PodcastRecord: Codable, FetchableRecord, PersistableRecord, Sendable {
    static let databaseTableName = "podcast"

    let id: String
    let title: String
    let link: String?
    let language: String
    let imageURL: String?
    let description: String
    let cachedAt: Date

    // Relationship to episodes
    static let episodes = hasMany(EpisodeRecord.self)

    /// Creates a record from a Business layer cached DTO.
    init(from cachedPodcast: CachedPodcast) {
        let podcast = cachedPodcast.podcast
        self.id = podcast.id.uuidString
        self.title = podcast.title
        self.link = podcast.link?.absoluteString
        self.language = podcast.language
        self.imageURL = podcast.imageURL?.absoluteString
        self.description = podcast.description
        self.cachedAt = cachedPodcast.cachedAt
    }

    /// Converts to Business layer cached DTO.
    func toCached() -> CachedPodcast {
        CachedPodcast(
            podcast: Podcast(
                id: UUID(uuidString: id)!,
                title: title,
                link: link.flatMap { URL(string: $0) },
                language: language,
                imageURL: imageURL.flatMap { URL(string: $0) },
                description: description,
                episodes: nil
            ),
            cachedAt: cachedAt
        )
    }

    /// Converts to Business layer cached DTO with episodes.
    func toCached(with episodes: [CachedEpisode]) -> CachedPodcast {
        CachedPodcast(
            podcast: Podcast(
                id: UUID(uuidString: id)!,
                title: title,
                link: link.flatMap { URL(string: $0) },
                language: language,
                imageURL: imageURL.flatMap { URL(string: $0) },
                description: description,
                episodes: episodes.map { $0.episode }
            ),
            cachedAt: cachedAt
        )
    }
}
