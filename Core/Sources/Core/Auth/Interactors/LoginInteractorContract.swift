import Foundation

public protocol LoginInteractorContract: Sendable {
    
    /// Authenticates a User with a server
    func callAsFunction(
        serverURL: String,
        username: String,
        password: String,
    ) async throws -> AuthSession
}
