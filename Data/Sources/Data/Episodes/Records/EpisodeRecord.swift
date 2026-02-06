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
        expiresOn > .now
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

extension EpisodeRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "episode"
    
    static let podcast = belongsTo(PodcastRecord.self)
    static let progress = hasOne(AudioProgressRecord.self)
    
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
