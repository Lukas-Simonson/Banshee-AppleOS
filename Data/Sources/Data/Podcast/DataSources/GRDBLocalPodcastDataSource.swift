import Business
import Core
import Foundation
import GRDB
import Logging

public struct GRDBLocalPodcastDataSource: LocalPodcastDataSourceContract {
    
    private let dbManager: DatabaseManager
    private let logger: Logger

    public init(dbManager: DatabaseManager, logger: Logger) {
        self.dbManager = dbManager
        self.logger = logger
    }
    
    public func observePodcast(with id: UUID) async throws(CoreError) -> AsyncSequence<CachedPodcast?, any Error> {
        ValueObservation.tracking { db in
            try PodcastRecord.fetchOne(db, key: id.uuidString)
        }
        .map { $0?.toCached() }
        .values(in: dbManager.dbQueue)
    }
    
    public func observePodcasts() async throws(CoreError) -> AsyncSequence<[CachedPodcast], any Error> {
        ValueObservation.tracking { db in
            try PodcastRecord.fetchAll(db)
        }
        .map { records in records.map { $0.toCached() } }
        .values(in: dbManager.dbQueue)
    }
    
    public func podcast(with id: UUID) async throws(CoreError) -> CachedPodcast? {
        try await CoreError.catchDatabase(performing: "fetching cached podcast with id: \(id)", logger: logger, feature: .podcasts) {
            try await dbManager.dbQueue.read { db in
                return try PodcastRecord.fetchOne(db, key: id.uuidString)
            }?.toCached()
        }
    }
    
    public func podcasts() async throws(CoreError) -> [CachedPodcast] {
        try await CoreError.catchDatabase(performing: "fetching cached podcasts", logger: logger, feature: .podcasts) {
            return try await dbManager.dbQueue.read { db in
                return try PodcastRecord.fetchAll(db)
            }.map { $0.toCached() }
        }
    }
    
    public func upsert(_ podcasts: [Podcast]) async throws(CoreError) {
        try await CoreError.catchDatabase(performing: "upserting podcasts", logger: logger, feature: .podcasts) {
            let records = podcasts.map { PodcastRecord(from: CachedPodcast(podcast: $0)) }
            try await dbManager.dbQueue.write { db in
                for record in records {
                    try record.upsert(db)
                }
            }
        }
    }
}
