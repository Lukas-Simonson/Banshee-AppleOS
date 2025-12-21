import Foundation

public protocol AuthRepositoryContract: Sendable {
    
    // MARK: - Session Management
    var session: AuthSession? { get async }
    var sessionStream: AsyncSequence<AuthSession?, Never> { get }
    
    func login(baseURL: String, username: String, password: String) async throws(AuthRepositoryError)
    func logout() async throws(AuthRepositoryError)
}

public enum AuthRepositoryError: String, LocalizedError {
    case unableToReachServer = "Server is unreachable, please check the URL and try again."
    case unableToLogin = "Unable to login"
    case unableToSaveSession = "Unable to save session locally"
    case unableToClearSession = "Unable to clear session locally"
    
    public var errorDescription: String { self.rawValue }
}
