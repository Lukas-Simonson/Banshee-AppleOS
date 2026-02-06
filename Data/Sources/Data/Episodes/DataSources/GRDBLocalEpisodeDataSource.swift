import Business
import Core
import Foundation
import GRDB
import Logging

public struct GRDBLocalEpisodeDataSource: LocalEpisodeDataSourceContract {
    
    private let dbManager: DatabaseManager
    private let logger: Logger
    
    public init(dbManager: DatabaseManager, logger: Logger) {
        self.dbManager = dbManager
        self.logger = logger
    }
    
    public func observeEpisodes(with podcastID: UUID) async throws(CoreError) -> AsyncSequence<[CachedEpisode], any Error> {
        ValueObservation.tracking { db in
            try EpisodeRecord
                .filter(EpisodeRecord.Columns.podcastID == podcastID)
                .including(optional: EpisodeRecord.progress)
                .asRequest(of: EpisodeRecord.Info.self)
                .fetchAll(db)
        }
        .values(in: dbManager.dbQueue)
    }
    
    public func episodes(with podcastID: UUID) async throws(CoreError) -> [CachedEpisode] {
        try await CoreError.catchDatabase(
            performing: "fetching episodes of podcast with id: \(podcastID)",
            logger: logger,
            feature: .episodes
        ) {
            try await dbManager.dbQueue.read { db in
                return try EpisodeRecord
                    .filter(EpisodeRecord.Columns.podcastID == podcastID)
                    .including(optional: EpisodeRecord.progress)
                    .asRequest(of: EpisodeRecord.Info.self)
                    .fetchAll(db)
            }
        }
    }
    
    public func upsert(_ episodes: [Episode], with podcastID: UUID) async throws(CoreError) {
        try await CoreError.catchDatabase(performing: "upserting episodes", logger: logger, feature: .episodes) {
            let records = episodes.map { $0.toRecord(with: podcastID) }
            try await dbManager.dbQueue.write { db in
                for record in records {
                    try record.upsert(db)
                }
            }
        }
    }
}
