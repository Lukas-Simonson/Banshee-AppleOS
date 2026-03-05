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
    
    public func observeEpisodes(with podcastID: UUID, order: Episode.Order) async throws(CoreError) -> AsyncSequence<[CachedEpisode], any Error> {
        ValueObservation.tracking { db in
            try EpisodeRecord
                .filter(EpisodeRecord.Columns.podcastID == podcastID)
                .order { convertEpisodeOrder(order: order, request: $0) }
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
    
    public func updateEpisodeCompletion(
        with id: UUID,
        isComplete: Bool
    ) async throws(CoreError) {
        try await CoreError.catchDatabase(performing: "updating audio progress for episode with id: \(id)", logger: logger, feature: .episodes) {
            try await dbManager.dbQueue.write { db in
                let current = try AudioProgressRecord
                    .fetchOne(db, key: id)
                
                // If we are making it not-completed, delete the progress.
                if !isComplete {
                    try current?.delete(db)
                    return
                }
                
                try AudioProgress(
                    isCompleted: isComplete,
                    watchTime: current?.watchTime ?? 0,
                    startedOn: current?.startedOn ?? .now,
                    lastUpdated: current?.lastUpdated ?? .now
                )
                .toRecord(with: id)
                .save(db)
            }
        }
    }
    
    private func convertEpisodeOrder(order: Episode.Order, request: QueryInterfaceRequest<EpisodeRecord>.DatabaseComponents) -> [SQLOrderingTerm] {
        switch order {
            case .title(let asc): asc ? [request.title.asc] : [request.title.desc]
            case .date(let asc): asc ? [request.pubDate.asc] : [request.pubDate.desc]
            case .seasonEpisode(let asc): asc ? [
                request.season.ascNullsLast,
                request.episode.ascNullsLast
            ] : [
                request.season.desc,
                request.episode.desc
            ]
        }
    }
}
