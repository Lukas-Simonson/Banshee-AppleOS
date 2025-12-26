import Core
import Foundation

public protocol RemoteAuthDataSourceContract: Sendable {
    
    /// Authenticates with Banshee-Server
    func login(baseURL: String, username: String, password: String) async throws(RemoteAuthDataSourceError) -> AuthSession
    
    func verifyServer(baseURL: String) async throws(RemoteAuthDataSourceError)
}

public enum RemoteAuthDataSourceError: String, LocalizedError {
    case urlError = "Unable to validate server url"
    case invalidCredentials = "Invalid username or password"
    case serverError = "Server error"
    case serverUnavailable = "Server unavailable"
    case invalidResponseFormat = "Invalid response format"
    case networkUnavailable = "Network unavailable"
    case requestTimeout = "Request timeout"
    case unexpectedResponse = "Unexpected response from server"
    case unknownError = "Unknown Error"

    public var errorDescription: String? { self.rawValue }
}
