import Core
import Foundation

public protocol RemoteAuthDataSourceContract: Sendable {
    
    /// Authenticates with Banshee-Server
    func login(baseURL: String, username: String, password: String) async throws(RemoteAuthDataSourceError) -> AuthSession
    
    func verifyServer(baseURL: String) async throws(RemoteAuthDataSourceError)
}

public enum RemoteAuthDataSourceError: String, LocalizedError {
    case urlError = "Unable to validate server url"
    case unexpectedResponse = "Unexpected response from server"
    case unknownError = "Unknown Erorr"
    
    var errorDescription: String { self.rawValue }
}
