import Core
import Foundation
import Logging
import Observation

@MainActor @Observable
final class LoginVM {
    
    // MARK: - Dependencies
    private let navigator: AuthNavigationContract
    private let repository: AuthRepositoryContract
    private let logger: Logger
    
    // MARK: - State
    public var serverURL: String = ""
    public var username: String = ""
    public var password: String = ""
    
    public var isLoading: Bool = false
    
    public var isLoginEnabled: Bool {
        !serverURL.isEmpty && !username.isEmpty && !password.isEmpty && !isLoading
    }
    
    // MARK: - Initialization
    init(_ scaffold: AuthScaffoldContract) {
        navigator = scaffold.navigator()
        repository = scaffold.repository()
        logger = scaffold.logger()
    }
    
    // MARK: - Actions
    
    public func login() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            logger.info("Login initiated from UI")
            
            do {
                try await repository.login(baseURL: serverURL, username: username, password: password)
                logger.info("Login successful, navigating to home!")
                navigator.navigateHome()
            } catch let error as CoreError {
                navigator.showError(error)
            }
        }
    }
}

