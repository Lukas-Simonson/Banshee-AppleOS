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

        // Launches a detached task to load initial state of authentication (re-logging)
        self.load()
    }

    // MARK: - Session Management
    public func login(baseURL: String, username: String, password: String) async throws(CoreError) {
        // Verify Server exists
        try await remote.verifyServer(baseURL: baseURL)

        // Attempt to login
        let session = try await remote.login(baseURL: baseURL, username: username, password: password)

        // Save session to local data source
        try await local.saveSession(session)

        // Update subscribers
        await sessionFlow.emit(session)
    }
    
    public func setupAdmin(baseURL: String, name: String, email: String, username: String, password: String) async throws(CoreError) {
        // Verify Server exists
        try await remote.verifyServer(baseURL: baseURL)
        
        // Attempt to register the admin
        let session = try await remote.setupAdmin(baseURL: baseURL, name: name, email: email, username: username, password: password)
        
        // Save session to local data source
        try await local.saveSession(session)
        
        // Update subscribers
        await sessionFlow.emit(session)
    }

    public func logout() async throws(CoreError) {
        try await local.clearSession()

        // Update Subscribers
        await sessionFlow.emit(nil)
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

extension CoreError {
    static var unableToSaveLocalSession: CoreError {
        CoreError(
            layer: .data,
            feature: .auth,
            code: 50,
            localizedKey: "error.data.auth.unableToSaveLocalSession",
            logMessage: "Failed to save authentication session data successfully."
        )
    }

    static var unableToDeleteLocalSession: CoreError {
        CoreError(
            layer: .data,
            feature: .auth,
            code: 51,
            localizedKey: "error.data.auth.unableToDeleteLocalSession",
            logMessage: "Failed to delete authentication session data successfully."
        )
    }
}
