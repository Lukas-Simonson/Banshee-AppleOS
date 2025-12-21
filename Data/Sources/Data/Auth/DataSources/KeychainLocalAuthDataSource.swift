import Business
import Core
import Foundation
import Logging
import Security

// @unchecked Sendable as UserDefaults is not sendable, but should work for our usage.
public final class LocalAuthDataSource: LocalAuthDataSourceContract, @unchecked Sendable {
    
    private let keychain: KeychainService
    private let defaults: UserDefaults
    private let logger: Logger
    
    public init(keychain: KeychainService, defaults: UserDefaults, logger: Logger) {
        self.keychain = keychain
        self.defaults = defaults
        self.logger = logger
    }
    
    public func getSession() async throws(LocalAuthDataSourceError) -> AuthSession? {
        do {
            // Get token from keychain
            guard let token = try keychain.get(key: Keys.token)
            else { return nil }
            
            // Get session from defaults
            guard let data = defaults.data(forKey: Keys.session) else {
                // Delete orphaned token
                try? keychain.delete(key: Keys.token)
                return nil
            }
            
            // Decode session
            let session = try JSONDecoder().decode(AuthSessionRecord.self, from: data)
            
            return session.toCore(with: token)
        }
        catch let error as KeychainService.KeychainError {
            logger.error("Unable to retrieve token from keychain", for: error)
            throw LocalAuthDataSourceError.unableToRetrieveToken
        }
        catch let error as DecodingError {
            logger.error("Unable to decode AuthSessionRecord", for: error)
            throw LocalAuthDataSourceError.unableToDecodeSession
        }
        catch {
            logger.error("Unexpected error found when getting session", for: error)
            throw LocalAuthDataSourceError.unknownError
        }
    }
    
    public func saveSession(_ session: AuthSession) async throws(LocalAuthDataSourceError) {
        do {
            // Save token to keychain
            try keychain.set(key: Keys.token, value: session.token.token)
            
            let record = AuthSessionRecord(from: session)
            
            let data = try JSONEncoder().encode(record)
            defaults.set(data, forKey: Keys.session)
        }
        catch let error as KeychainService.KeychainError {
            logger.error("Unable to save token to keychain", for: error)
            throw LocalAuthDataSourceError.unableToSaveToken
        }
        catch let error as EncodingError {
            logger.error("Unable to encode AuthSessionRecord", for: error)
            throw LocalAuthDataSourceError.unableToEncodeSession
        }
        catch {
            logger.error("Unexpected error found when saving session", for: error)
            throw LocalAuthDataSourceError.unknownError
        }
    }
    
    public func clearSession() async throws(LocalAuthDataSourceError) {
        do {
            try keychain.delete(key: Keys.token)
            defaults.removeObject(forKey: Keys.session)
        } catch let error as KeychainService.KeychainError {
            logger.error("Unable to delete token from keychain", for: error)
            throw LocalAuthDataSourceError.unableToSaveToken
        }
    }
}

extension LocalAuthDataSource {
    private enum Keys {
        static let session = "com.bansheeaudio.banshee.session"
        static let token = "com.bansheeaudio.banshee.token"
    }
}
