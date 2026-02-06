import Business
import Core
import Foundation
import GRDB

struct PodcastRecord: Sendable {
    let id: UUID
    let title: String
    let link: URL?
    let language: String
    let imageURL: URL?
    let description: String
    let expiresOn: Date
}

extension PodcastRecord: CachedPodcast {
    func isExpired() -> Bool {
        expiresOn < .now
    }
    
    func toCore() -> Podcast {
        Podcast(
            id: id,
            title: title,
            link: link,
            language: language,
            imageURL: imageURL,
            description: description
        )
    }
}

extension Podcast {
    func toRecord() -> PodcastRecord {
        PodcastRecord(
            id: id,
            title: title,
            link: link,
            language: language,
            imageURL: imageURL,
            description: description,
            expiresOn: .now + PodcastRecord.expiration
        )
    }
}

extension PodcastRecord: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "podcast"
    
    static let episodes = hasMany(EpisodeRecord.self)
    
    enum Columns: String, ColumnExpression {
        case id, title, link, language, imageURL, description, expiresOn
    }
    
    enum Migration {
        static func create(_ db: Database) throws {
            try db.create(table: "podcast") { t in
                t.primaryKey("id", .text).notNull()
                t.column("title", .text).notNull()
                t.column("link", .text)
                t.column("language", .text).notNull()
                t.column("imageURL", .text)
                t.column("description", .text).notNull()
                t.column("expiresOn", .datetime).notNull()
            }
        }
    }
}
