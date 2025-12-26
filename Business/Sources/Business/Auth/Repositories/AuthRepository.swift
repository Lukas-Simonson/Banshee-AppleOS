import Core
import Foundation
import Logging
import Overflow

public final class AuthRepository: AuthRepositoryContract {
    
    // MARK: - Private Properties
    private let local: LocalAuthDataSourceContract
    private let remote: RemoteAuthDataSourceContract
    private let logger: Logger
    
    /// Manages streaming data
    private let sessionFlow = MutableStateFlow<AuthSession?>(initial: nil)
    
    // MARK: - Shared State
    public var session: AuthSession? {
        get async { await sessionFlow.value }
    }
    
    public var sessionStream: any AsyncSequence<AuthSession?, Never> {
        sessionFlow
    }
    
    public init(
        local: LocalAuthDataSourceContract,
        remote: RemoteAuthDataSourceContract,
        logger: Logger
    ) {
        self.local = local
        self.remote = remote
        self.logger = logger
        
        // Launches a detatched task to load initial state of authentication (re-logging)
        self.load()
    }
    
    // MARK: - Session Management
    public func login(baseURL: String, username: String, password: String) async throws(AuthRepositoryError) {
        do {
            // Verify Server exists
            try await remote.verifyServer(baseURL: baseURL)
            
            // Attempt to login
            let session = try await remote.login(baseURL: baseURL, username: username, password: password)
            
            // Save session to local data source
            try await local.saveSession(session)
            
            // Update subscribers
            await sessionFlow.emit(session)
            
        }
        catch let error as RemoteAuthDataSourceError {

            logger.error("Unable to connect to server", for: error)
            throw AuthRepositoryError.unableToReachServer
        }
        catch let error as LocalAuthDataSourceError {

            logger.error("Unable to save session locally", for: error)
            throw AuthRepositoryError.unableToSaveSession
        }
        catch {
            logger.error("Unexpected error during login", for: error)
            throw AuthRepositoryError.unexpectedError
        }
    }
    
    public func logout() async throws(AuthRepositoryError) {
        do {
            try await local.clearSession()
            
            // Update Subscribers
            await sessionFlow.emit(nil)
        }
        catch let error as LocalAuthDataSourceError {
            logger.error("Unable to clear session", for: error)
            throw AuthRepositoryError.unableToClearSession
        }
    }
    
    // MARK: - Private API
    private func load() {
        Task {
            do {
                let session = try await local.getSession()
                logger.info("Loading existing session for: \(session?.user.username)")
                
                await sessionFlow.emit(session)
            } catch {
                logger.error("Failed to load initial state: \(error)")
            }
        }
    }
}
