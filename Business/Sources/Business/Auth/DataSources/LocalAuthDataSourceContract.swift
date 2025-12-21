import Core
import Foundation

/// Contract for secure local secret storage. (Keychain)
public protocol LocalAuthDataSourceContract: Sendable {
    
    func getSession() async throws(LocalAuthDataSourceError) -> AuthSession?
    
    func saveSession(_ session: AuthSession) async throws(LocalAuthDataSourceError)
    
    func clearSession() async throws(LocalAuthDataSourceError)
}

public enum LocalAuthDataSourceError: String, LocalizedError {
    case unableToSaveToken = "Unable to save data to local keychain"
    case unableToRetrieveToken = "Unable to retrieve token from local keychain"
    
    case unableToDecodeSession = "Login session data corrupted"
    case unableToEncodeSession = "Login session in an unexpected format"
    
    case unknownError = "An unexpected error happened"
    
    var errorDescription: String { self.rawValue }
}
