import Core
import Foundation

/// Contract for secure local secret storage. (Keychain)
public protocol LocalAuthDataSourceContract: Sendable {
    
    func getSession() async throws(LocalAuthDataSourceError) -> AuthSession
    
    func saveSession(_ session: AuthSession) async throws(LocalAuthDataSourceError)
    
    func clearSession() async throws(LocalAuthDataSourceError)
}

public enum LocalAuthDataSourceError: String, LocalizedError {
    case someError = "Something occurred"
    
    var errorDescription: String { self.rawValue }
}
