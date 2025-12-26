import Core
import Foundation

public protocol LocalPlayerDataSourceContract: Sendable {
    func updateProgress(
        episodeID: UUID,
        isCompleted: Bool,
        duration: Int
    ) async throws(LocalPlayerDataSourceError)
}

public enum LocalPlayerDataSourceError: String, LocalizedError {
    case unexpectedState = "Unexpected local state"
    case databaseError = "Failed to access local database"
    case dataCorruption = "Cached data is corrupted"
    case migrationFailed = "Database migration failed"
    case diskFull = "Storage space full"
    case databaseLocked = "Database is locked"
    case constraintViolation = "Data integrity constraint violated"
    case readOnlyDatabase = "Database is read-only"
    
    public var errorDescription: String? { self.rawValue }
}
