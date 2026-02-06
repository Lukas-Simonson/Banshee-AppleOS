import Business
import Core
import Foundation
import GRDB

/// GRDB Record for persisting Episode data.
struct EpisodeRecord: Codable, FetchableRecord, PersistableRecord, Sendable {
    static let databaseTableName = "episode"

    let id: String
    let podcastId: String
    let title: String
    let pubDate: Date
    let description: String
    let imageURL: String?
    let season: String?
    let episode: Int?
    let duration: Int?
    let cachedAt: Date

    // Relationship to podcast
    static let podcast = belongsTo(PodcastRecord.self)

    // Relationship to progress
    static let progress = hasOne(AudioProgressRecord.self, using: ForeignKey(["episodeId"]))

    /// Creates a record from a Business layer cached DTO.
    init(from cachedEpisode: CachedEpisode, podcastID: UUID) {
        let episode = cachedEpisode.episode
        self.id = episode.id.uuidString
        self.podcastId = podcastID.uuidString
        self.title = episode.title
        self.pubDate = episode.pubDate
        self.description = episode.description
        self.imageURL = episode.imageURL?.absoluteString
        self.season = episode.season
        self.episode = episode.episode
        self.duration = episode.duration
        self.cachedAt = cachedEpisode.cachedAt
    }

    /// Converts to Business layer cached DTO without progress.
    func toCached() -> CachedEpisode {
        CachedEpisode(
            episode: Episode(
                id: UUID(uuidString: id)!,
                title: title,
                pubDate: pubDate,
                description: description,
                imageURL: imageURL.flatMap { URL(string: $0) },
                season: season,
                episode: episode,
                duration: duration,
                progress: nil
            ),
            cachedAt: cachedAt
        )
    }

    /// Converts to Business layer cached DTO with progress.
    func toCached(with cachedProgress: CachedAudioProgress?) -> CachedEpisode {
        CachedEpisode(
            episode: Episode(
                id: UUID(uuidString: id)!,
                title: title,
                pubDate: pubDate,
                description: description,
                imageURL: imageURL.flatMap { URL(string: $0) },
                season: season,
                episode: episode,
                duration: duration,
                progress: cachedProgress?.progress
            ),
            cachedAt: cachedAt
        )
    }
    
    struct Info: Codable, FetchableRecord {
        var episodeRecord: EpisodeRecord
        var audioProgress: AudioProgressRecord?
        
        func toCached() -> CachedEpisode {
            CachedEpisode(
                episode: Episode(
                    id: UUID(uuidString: episodeRecord.id)!,
                    title: episodeRecord.title,
                    pubDate: episodeRecord.pubDate,
                    description: episodeRecord.description,
                    imageURL: episodeRecord.imageURL.flatMap { URL(string: $0) },
                    season: episodeRecord.season,
                    episode: episodeRecord.episode,
                    duration: episodeRecord.duration,
                    progress: audioProgress?.toCached().progress
                ),
                cachedAt: episodeRecord.cachedAt
            )
        }
    }
}
