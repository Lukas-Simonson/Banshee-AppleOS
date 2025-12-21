import Foundation

public protocol LogoutInteractorContract: Sendable {
    
    /// Logout current user and clear the session.
    func callAsFunction() async throws
}
