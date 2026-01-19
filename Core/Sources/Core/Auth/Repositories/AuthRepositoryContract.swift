import Foundation

public protocol AuthRepositoryContract: Sendable {
    
    // MARK: - Session Management
    var session: AuthSession? { get async }
    var sessionStream: AsyncSequence<AuthSession?, Never> { get }
    
    func login(baseURL: String, username: String, password: String) async throws(CoreError)
    func logout() async throws(CoreError)
}
