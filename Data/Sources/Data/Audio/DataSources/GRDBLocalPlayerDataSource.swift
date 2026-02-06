import Business
import Core
import Foundation
import GRDB
import Logging

public final class GRDBLocalPlayerDataSource: LocalPlayerDataSourceContract {
    
    private let dbManager: DatabaseManager
    private let logger: Logger
    
    public init(dbManager: DatabaseManager, logger: Logger) {
        self.dbManager = dbManager
        self.logger = logger
    }
    
    public func updateProgress(
        episodeID: UUID,
        isCompleted: Bool,
        watchTime: Int
    ) async throws(CoreError) {
        try await CoreError.catchDatabase(performing: "updating audio progress for episode with id: \(episodeID)", logger: logger, feature: .audio) {
            let cachedAt = Date()
            try await dbManager.dbQueue.write { db in
                let current = try AudioProgressRecord
                    .fetchOne(db, key: episodeID)
                
                try AudioProgress(
                    isCompleted: isCompleted,
                    watchTime: watchTime,
                    startedOn: current?.startedOn ?? cachedAt,
                    lastUpdated: cachedAt
                )
                .toRecord(with: episodeID)
                .save(db)
            }
        }
    }
}
