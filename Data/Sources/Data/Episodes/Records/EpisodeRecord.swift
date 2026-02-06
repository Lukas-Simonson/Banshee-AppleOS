import Business
import Core
import Foundation
import GRDB

struct EpisodeRecord: Sendable {
    let id: UUID
    let title: String
    let pubDate: Date
    let description: String
    let imageURL: URL?
    let season: String?
    let episode: Int?
    let duration: Int?
    let expiresOn: Date
    
    let podcastID: UUID
}

extension EpisodeRecord: CachedEpisode {
    func isExpired() -> Bool {
        expiresOn < .now
    }
    
    func toCore() -> Episode {
        Episode(
            id: id,
            title: title,
            pubDate: pubDate,
            description: description,
            imageURL: imageURL,
            season: season,
            episode: episode,
            duration: duration,
            progress: nil
        )
    }
}

extension Episode {
    func toRecord(with podcastID: UUID) -> EpisodeRecord {
        EpisodeRecord(
            id: id,
            title: title,
            pubDate: pubDate,
            description: description,
            imageURL: imageURL,
            season: season,
            episode: episode,
            duration: duration,
            expiresOn: .now + EpisodeRecord.expiration,
            podcastID: podcastID
        )
    }
}

extension EpisodeRecord: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "episode"
    
    static let podcast = belongsTo(PodcastRecord.self)
    static let progress = hasOne(AudioProgressRecord.self)
    
    enum Columns: String, ColumnExpression {
        case id, title, pubDate, description, imageURL, season, episode, duration, expiresOn, podcastID
    }
    
    enum Migration {
        static func create(_ db: Database) throws {
            try db.create(table: "episode") { t in
                t.primaryKey("id", .text).notNull()
                t.column("title", .text).notNull()
                t.column("pubDate", .datetime).notNull()
                t.column("description", .text).notNull()
                t.column("imageURL", .text)
                t.column("season", .text)
                t.column("episode", .integer)
                t.column("duration", .integer)
                t.column("expiresOn", .datetime).notNull()
                t.column("podcastID", .text)
                    .notNull()
                    .references("podcast", onDelete: .cascade)
            }
        }
    }
}

extension EpisodeRecord {
    struct Info: Codable, FetchableRecord, CachedEpisode {
        let episodeRecord: EpisodeRecord
        let audioProgress: AudioProgressRecord?
        
        func isExpired() -> Bool {
            episodeRecord.isExpired()
        }
        
        func toCore() -> Episode {
            Episode(
                id: episodeRecord.id,
                title: episodeRecord.title,
                pubDate: episodeRecord.pubDate,
                description: episodeRecord.description,
                imageURL: episodeRecord.imageURL,
                season: episodeRecord.season,
                episode: episodeRecord.episode,
                duration: episodeRecord.duration,
                progress: audioProgress?.toCore()
            )
        }
    }
}
