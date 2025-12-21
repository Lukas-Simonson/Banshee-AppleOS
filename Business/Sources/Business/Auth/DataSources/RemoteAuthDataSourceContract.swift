import Core
import Foundation

public protocol RemoteAuthDataSourceContract: Sendable {
    
    /// Authenticates with Banshee-Server
    func login(baseURL: String, username: String, password: String) async throws(RemoteAuthDataSourceError) -> AuthSession
    
    func verifyServer(baseURL: String) async throws(RemoteAuthDataSourceError)
}

public enum RemoteAuthDataSourceError: String, LocalizedError {
    case someError = "Something occurred"
    
    var errorDescription: String { self.rawValue }
}
