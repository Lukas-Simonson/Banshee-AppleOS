import Core
import Foundation

public protocol RemoteAuthDataSourceContract: Sendable {
    
    /// Authenticates with Banshee-Server
    func login(baseURL: String, username: String, password: String) async throws(CoreError) -> AuthSession

    /// Verifies server is up and running
    func verifyServer(baseURL: String) async throws(CoreError)
}
