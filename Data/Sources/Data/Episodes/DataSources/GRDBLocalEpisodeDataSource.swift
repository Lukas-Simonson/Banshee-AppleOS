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
                .filter(Column("podcastId") == podcastID.uuidString)
                .including(optional: EpisodeRecord.progress)
                .asRequest(of: EpisodeRecord.Info.self)
                .fetchAll(db)
        }
        .map { records in records.map { $0.toCached() } }
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
                    .filter(Column("podcastID") == podcastID.uuidString)
                    .including(optional: EpisodeRecord.progress)
                    .asRequest(of: EpisodeRecord.Info.self)
                    .fetchAll(db)
            }
            .map { $0.toCached() }
        }
    }
    
    public func upsert(_ episodes: [Core.Episode], with podcastID: UUID) async throws(CoreError) {
        try await CoreError.catchDatabase(performing: "upserting episodes", logger: logger, feature: .episodes) {
            let records = episodes.map { EpisodeRecord(from: CachedEpisode(episode: $0), podcastID: podcastID) }
            try await dbManager.dbQueue.write { db in
                for record in records {
                    try record.upsert(db)
                }
            }
        }
    }
}
