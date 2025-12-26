import Foundation

public protocol AuthRepositoryContract: Sendable {
    
    // MARK: - Session Management
    var session: AuthSession? { get async }
    var sessionStream: AsyncSequence<AuthSession?, Never> { get }
    
    func login(baseURL: String, username: String, password: String) async throws(AuthRepositoryError)
    func logout() async throws(AuthRepositoryError)
}

public enum AuthRepositoryError: CoreError {
    case unableToReachServer
    case unableToLogin
    case unableToSaveSession
    case unableToClearSession
    case unexpectedError

    public var errorCode: UInt16 {
        switch self {
        case .unableToReachServer: 101
        case .unableToLogin: 102
        case .unableToSaveSession: 103
        case .unableToClearSession: 104
        case .unexpectedError: 105
        }
    }

    public var localizeableKey: LocalizedStringResource {
        switch self {
        case .unableToReachServer: "error.auth.unableToReachServer"
        case .unableToLogin: "error.auth.unableToLogin"
        case .unableToSaveSession: "error.auth.unableToSaveSession"
        case .unableToClearSession: "error.auth.unableToClearSession"
        case .unexpectedError: "error.auth.unexpectedError"
        }
    }

    public var logMessage: String {
        switch self {
        case .unableToReachServer:
            "Failed to connect to server - network unreachable or invalid URL"
        case .unableToLogin:
            "Authentication failed - invalid credentials or server error"
        case .unableToSaveSession:
            "Failed to persist authentication session to local storage"
        case .unableToClearSession:
            "Failed to clear authentication session from local storage"
        case .unexpectedError:
            "Unexpected error occurred during authentication"
        }
    }
}
