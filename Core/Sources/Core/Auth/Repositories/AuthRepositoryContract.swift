import Foundation

public protocol AuthRepositoryContract: Sendable {
    
    // MARK: - Session Management
    var session: AuthSession? { get async }
    var sessionStream: AsyncSequence<AuthSession?, Never> { get }
    
    func saveSession(_ session: AuthSession) async throws
    func clearSession() async throws
}
