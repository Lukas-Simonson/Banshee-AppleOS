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
        do {
            let cachedAt = Date()
            try await dbManager.dbQueue.write { db in
                let current = try AudioProgressRecord
                    .fetchOne(db, key: episodeID.uuidString)?
                    .toCached()
                    .toCore()
                
                let new = AudioProgress(
                    isCompleted: isCompleted,
                    watchTime: watchTime,
                    startedOn: current?.startedOn ?? cachedAt,
                    lastUpdated: cachedAt
                )
                
                try AudioProgressRecord(
                    from: CachedAudioProgress(progress: new, cachedAt: cachedAt),
                    episodeId: episodeID
                ).save(db)
            }
        } catch let error as DatabaseError {
            logger.error("Encountered error when updating progress for episode with id: \(episodeID)", for: error)
            throw error.toCoreError(for: .audio)
        } catch {
            logger.error("Encountered an unexpected error when updating progress for episode with id: \(episodeID)", for: error)
            throw CoreError.unexpected(layer: .data, feature: .audio)
        }
    }
}
