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
        duration: Int
    ) async throws(Business.LocalPlayerDataSourceError) {
        do {
            let cachedAt = Date()
            try await dbManager.dbQueue.write { db in
                let current = try AudioProgressRecord
                    .fetchOne(db, key: episodeID.uuidString)?
                    .toCached()
                    .toCore()
                
                let new = AudioProgress(
                    isCompleted: isCompleted,
                    duration: duration,
                    startedOn: current?.startedOn ?? cachedAt,
                    lastUpdated: cachedAt
                )
                
                try AudioProgressRecord(
                    from: CachedAudioProgress(progress: new, cachedAt: cachedAt),
                    episodeId: episodeID
                ).save(db)
            }
        } catch {
            logger.error("Failed to update progress for episode", for: error)
            throw mapDatabaseError(error)
        }
    }
    
    /// Maps GRDB errors to specific LocalPodcastDataSourceError cases
    private func mapDatabaseError(_ error: Error) -> LocalPlayerDataSourceError {
        if let dbError = error as? DatabaseError {
            switch dbError.resultCode {
                case .SQLITE_FULL, .SQLITE_IOERR:
                    return .diskFull
                case .SQLITE_BUSY, .SQLITE_LOCKED:
                    return .databaseLocked
                case .SQLITE_CONSTRAINT:
                    return .constraintViolation
                case .SQLITE_READONLY:
                    return .readOnlyDatabase
                case .SQLITE_CORRUPT, .SQLITE_NOTADB:
                    return .dataCorruption
                default:
                    return .databaseError
            }
        }
        return .databaseError
    }
}
