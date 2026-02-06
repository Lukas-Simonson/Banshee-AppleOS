import Core
import GRDB
import Logging

extension CoreError {
    
    static func catchDatabase(
        performing: String,
        logger: Logger,
        feature: Feature,
        _ action: () async throws -> Void
    ) async throws(CoreError) {
        try await catchDatabase(performing: performing, logger: logger, feature: feature) {
            try await action()
        }
    }
    
    static func catchDatabase<T>(
        performing: String,
        logger: Logger,
        feature: Feature,
        _ action: () async throws -> T
    ) async throws(CoreError) -> T {
        do {
            return try await action()
        } catch let error as DatabaseError {
            logger.error("Failed to \(performing)", for: error)
            throw error.toCoreError(for: feature)
        } catch let error as CoreError {
            throw error
        } catch {
            logger.error("Unexpected error while \(performing)", for: error)
            throw CoreError.unexpected(layer: .data, feature: feature)
        }
    }
}
