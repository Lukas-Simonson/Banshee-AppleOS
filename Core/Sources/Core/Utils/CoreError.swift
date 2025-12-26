import Foundation

public protocol CoreError: LocalizedError {

    /// A 3 digit number used to easily identify an error.
    /// The first number marks the domain of the error, the next two identify the error within that domain.
    var errorCode: UInt16 { get }

    /// A localized string resource key.
    var localizeableKey: LocalizedStringResource { get }

    /// A more detailed description of the error, used for logging.
    var logMessage: String { get }
}

public extension CoreError {
    /// Default implementation of LocalizedError.errorDescription
    /// Uses the localizeableKey to provide localized user-facing messages
    var errorDescription: String? {
        String(localized: localizeableKey)
    }
}
