import Core
import GRDB

extension DatabaseError {
    func toCoreError(for feature: CoreError.Feature) -> CoreError {
        switch resultCode {
            case .SQLITE_FULL, .SQLITE_IOERR:
                CoreError.diskFull(layer: .data, feature: feature)
            case .SQLITE_BUSY, .SQLITE_LOCKED:
                CoreError.databaseLocked(layer: .data, feature: feature)
            case .SQLITE_CONSTRAINT:
                CoreError.constraintViolation(layer: .data, feature: feature)
            case .SQLITE_READONLY:
                CoreError.readOnlyDatabase(layer: .data, feature: feature)
            case .SQLITE_CORRUPT, .SQLITE_NOTADB:
                CoreError.dataCorrupted(layer: .data, feature: feature)
            default:
                CoreError.databaseError(layer: .data, feature: feature)
        }
    }
}
