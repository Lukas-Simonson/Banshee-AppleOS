import Foundation

public struct CoreError: LocalizedError {
    public let id = UUID()
    public let errorCode: UInt16
    public let localizedKey: LocalizedStringResource
    public let logMessage: String

    /// Creates a CoreError using a provided origin layer, code, localizedKey, and logMessage.
    ///
    /// The code should begin greater than 50 and less than 100, for non-shared errors.
    public init(
        layer: Layer,
        feature: Feature,
        code: UInt16,
        localizedKey: LocalizedStringResource,
        logMessage: String
    ) {
        assert(code < 100, "CoreError code must be between 0 & 99")

        self.errorCode = layer.rawValue + feature.rawValue + code
        self.localizedKey = localizedKey
        self.logMessage = logMessage
    }

    public var errorDescription: String? {
        String(localized: localizedKey)
    }
}

public extension CoreError {
    enum Layer: UInt16 {
        case core = 1_00_00
        case feature = 2_00_00
        case business = 3_00_00
        case data = 4_00_00
        case app = 5_00_00
    }

    enum Feature: UInt16 {
        case audio = 00_01_00
        case auth = 00_02_00
        case podcasts = 00_03_00
        case episodes = 00_04_00
        case settings = 00_05_00
    }
}

// MARK: - Shared Errors
public extension CoreError {
    /// Unexpected Error, code 00
    static func unexpected(layer: Layer, feature: Feature) -> CoreError {
        CoreError(
            layer: layer,
            feature: feature,
            code: 0,
            localizedKey: "error.core.unexpected",
            logMessage: "An unexpected error occurred, originating from layer: \(layer.rawValue)"
        )
    }

    /// User Not Authenticated, code 01
    static func notAuthenticated(layer: Layer, feature: Feature) -> CoreError {
        CoreError(
            layer: layer,
            feature: feature,
            code: 1,
            localizedKey: "error.core.unauthorized",
            logMessage: "User was not authorized to perform an action"
        )
    }

    /// Unable to reach server, code 402
    static func serverUnreachable(feature: Feature) -> CoreError {
        CoreError(
            layer: .data,
            feature: feature,
            code: 2,
            localizedKey: "error.core.serverUnreachable",
            logMessage: "Unable to connect to the server"
        )
    }
    
    /// Invalid / Unknown ID, code 03
    static func unknownOrInvalidID<T>(for type: T.Type, layer: Layer, feature: Feature) -> CoreError {
        CoreError(
            layer: layer,
            feature: feature,
            code: 3,
            localizedKey: "error.core.unexpected",
            logMessage: "Unknown or Invalid id provided for type: \(type)"
        )
    }
}

// MARK: - Network Errors
public extension CoreError {
    static func urlError(layer: Layer, feature: Feature) -> CoreError {
        CoreError(
            layer: layer,
            feature: feature,
            code: 20,
            localizedKey: "error.network.urlError",
            logMessage: "Unable to validate server url"
        )
    }

    static func serverError(layer: Layer, feature: Feature) -> CoreError {
        CoreError(
            layer: layer,
            feature: feature,
            code: 21,
            localizedKey: "error.network.serverError",
            logMessage: "The connected server reported an 5xx status code"
        )
    }

    static func invalidResponseFormat(layer: Layer, feature: Feature) -> CoreError {
        CoreError(
            layer: layer,
            feature: feature,
            code: 22,
            localizedKey: "error.network.invalidResponseFormat",
            logMessage: "Received a response in an invalid or unexpected format."
        )
    }

    static func networkUnavailable(layer: Layer, feature: Feature) -> CoreError {
        CoreError(
            layer: layer,
            feature: feature,
            code: 23,
            localizedKey: "error.network.networkUnavailable",
            logMessage: "The network is unavailable"
        )
    }

    static func requestTimeout(layer: Layer, feature: Feature) -> CoreError {
        CoreError(
            layer: layer,
            feature: feature,
            code: 24,
            localizedKey: "error.network.requestTimeout",
            logMessage: "The network request timed out"
        )
    }

    static func unexpectedResponse(layer: Layer, feature: Feature, code: Int) -> CoreError {
        CoreError(
            layer: layer,
            feature: feature,
            code: 25,
            localizedKey: "error.network.unexpectedResponse",
            logMessage: "Received an unexpected response code from the server. Code: \(code)"
        )
    }

    static func unauthorized(layer: Layer, feature: Feature) -> CoreError {
        CoreError(
            layer: layer,
            feature: feature,
            code: 26,
            localizedKey: "error.core.unauthorized",
            logMessage: "User must be authorized to perform this action"
        )
    }

    static func resourceNotFound(layer: Layer, feature: Feature) -> CoreError {
        CoreError(
            layer: layer,
            feature: feature,
            code: 26,
            localizedKey: "error.network.notFound",
            logMessage: "Unable to find a matching resource"
        )
    }
}

// MARK: - Database Errors
public extension CoreError {

    static func databaseError(layer: Layer, feature: Feature) -> CoreError {
        CoreError(
            layer: layer,
            feature: feature,
            code: 30,
            localizedKey: "error.database.databaseError",
            logMessage: "Failed to access local database"
        )
    }

    static func dataCorrupted(layer: Layer, feature: Feature) -> CoreError {
        CoreError(
            layer: layer,
            feature: feature,
            code: 31,
            localizedKey: "error.database.dataCorrupted",
            logMessage: "Database data is corrupted"
        )
    }

    static func migrationFailed(layer: Layer, feature: Feature) -> CoreError {
        CoreError(
            layer: layer,
            feature: feature,
            code: 32,
            localizedKey: "error.database.migrationFailed",
            logMessage: "Database migration failed"
        )
    }

    static func diskFull(layer: Layer, feature: Feature) -> CoreError {
        CoreError(
            layer: layer,
            feature: feature,
            code: 33,
            localizedKey: "error.database.diskFull",
            logMessage: "Storage space is full"
        )
    }

    static func databaseLocked(layer: Layer, feature: Feature) -> CoreError {
        CoreError(
            layer: layer,
            feature: feature,
            code: 34,
            localizedKey: "error.database.databaseLocked",
            logMessage: "Database is locked"
        )
    }

    static func constraintViolation(layer: Layer, feature: Feature) -> CoreError {
        CoreError(
            layer: layer,
            feature: feature,
            code: 35,
            localizedKey: "error.database.constraintViolation",
            logMessage: "Data integrity constraint violated"
        )
    }

    static func readOnlyDatabase(layer: Layer, feature: Feature) -> CoreError {
        CoreError(
            layer: layer,
            feature: feature,
            code: 36,
            localizedKey: "error.database.readOnlyDatabase",
            logMessage: "The database is in read-only mode"
        )
    }
}
