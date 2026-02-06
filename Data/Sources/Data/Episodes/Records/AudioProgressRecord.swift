import Business
import Core
import Foundation
import GRDB

struct AudioProgressRecord: Sendable {
    
    //    let episodeId: String
    //    let isCompleted: Bool
    //    let watchTime: Int
    //    let startedOn: Date
    //    let lastUpdated: Date
    //    let cachedAt: Date
    
    let episodeID: UUID
    let isCompleted: Bool
    let watchTime: Int
    let startedOn: Date
    let lastUpdated: Date
    let expiresOn: Date
}

//extension EpisodeRecord: CachedEpisode {
//    func isExpired() -> Bool {
//        expiresOn > .now
//    }
//    
//    func toCore() -> Episode {
//        Episode(
//            id: id,
//            title: title,
//            pubDate: pubDate,
//            description: description,
//            imageURL: imageURL,
//            season: season,
//            episode: episode,
//            duration: duration,
//            progress: nil
//        )
//    }
//}
//
//extension EpisodeRecord: Codable, FetchableRecord, PersistableRecord {
//    static let databaseTableName = "episode"
//    
//    static let podcast = belongsTo(PodcastRecord.self)
//    static let progress = hasOne(AudioProgressRecord.self)
//    
//    enum Migration {
//        static func create(_ db: Database) throws {
//            try db.create(table: "episode") { t in
//                t.primaryKey("id", .text).notNull()
//                t.column("title", .text).notNull()
//                t.column("pubDate", .datetime).notNull()
//                t.column("description", .text).notNull()
//                t.column("imageURL", .text)
//                t.column("season", .text)
//                t.column("episode", .integer)
//                t.column("duration", .integer)
//                t.column("expiresOn", .datetime).notNull()
//                t.column("podcastID", .text)
//                    .notNull()
//                    .references("podcast", onDelete: .cascade)
//            }
//        }
//    }
//}

///// GRDB Record for persisting AudioProgress data.
//struct AudioProgressRecord: Codable, FetchableRecord, PersistableRecord, Sendable {
//    static let databaseTableName = "audioProgress"
//
//    let episodeId: String
//    let isCompleted: Bool
//    let watchTime: Int
//    let startedOn: Date
//    let lastUpdated: Date
//    let cachedAt: Date
//
//    // Relationship to episode
//    static let episode = belongsTo(EpisodeRecord.self, using: ForeignKey(["episodeId"]))
//
//    /// Creates a record from a Business layer cached DTO.
//    init(from cachedProgress: CachedAudioProgress, episodeId: UUID) {
//        let progress = cachedProgress.progress
//        self.episodeId = episodeId.uuidString
//        self.isCompleted = progress.isCompleted
//        self.watchTime = progress.watchTime
//        self.startedOn = progress.startedOn
//        self.lastUpdated = progress.lastUpdated
//        self.cachedAt = cachedProgress.cachedAt
//    }
//
//    /// Converts to Business layer cached DTO.
//    func toCached() -> CachedAudioProgress {
//        CachedAudioProgress(
//            progress: AudioProgress(
//                isCompleted: isCompleted,
//                watchTime: watchTime,
//                startedOn: startedOn,
//                lastUpdated: lastUpdated
//            ),
//            cachedAt: cachedAt
//        )
//    }
//}
