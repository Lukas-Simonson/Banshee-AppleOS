import Business
import Core
import Foundation
import GRDB

struct AudioProgressRecord: Sendable {
    let episodeID: UUID
    let isCompleted: Bool
    let watchTime: Int
    let startedOn: Date
    let lastUpdated: Date
    let expiresOn: Date
}

extension AudioProgressRecord: CachedAudioProgress {
    func isExpired() -> Bool {
        expiresOn < .now
    }
    
    func toCore() -> AudioProgress {
        AudioProgress(
            isCompleted: isCompleted,
            watchTime: watchTime,
            startedOn: startedOn,
            lastUpdated: lastUpdated
        )
    }
}

extension AudioProgress {
    func toRecord(with episodeID: UUID) -> AudioProgressRecord {
        AudioProgressRecord(
            episodeID: episodeID,
            isCompleted: isCompleted,
            watchTime: watchTime,
            startedOn: startedOn,
            lastUpdated: lastUpdated,
            expiresOn: .now + AudioProgressRecord.expiration
        )
    }
}

extension AudioProgressRecord: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "audioProgress"
    
    static let episode = belongsTo(EpisodeRecord.self)
    
    enum Migration {
        static func create(_ db: Database) throws {
            try db.create(table: "audioProgress") { t in
                t.primaryKey("episodeID", .text)
                    .references("episode", onDelete: .cascade)
                t.column("isCompleted", .boolean).notNull()
                t.column("watchTime", .integer).notNull()
                t.column("startedOn", .datetime).notNull()
                t.column("lastUpdated", .datetime).notNull()
                t.column("expiresOn", .datetime).notNull()
            }
        }
    }
}
