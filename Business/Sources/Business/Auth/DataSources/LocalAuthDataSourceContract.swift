import Core
import Foundation

/// Contract for secure local secret storage. (Keychain)
public protocol LocalAuthDataSourceContract: Sendable {
    
    func getSession() async throws(CoreError) -> AuthSession?
    
    func saveSession(_ session: AuthSession) async throws(CoreError)

    func clearSession() async throws(CoreError)
}
