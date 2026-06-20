import Core
import Logging
import Observation
import SharedUI

@MainActor @Observable
final class ServerSetupVM {
    // MARK: - Dependencies
    private let logger: Logger
    private let navigator: AuthNavigationContract
    private let repository: AuthRepositoryContract
    
    // MARK: - State
    var baseURL = Validated("")
    var name = Validated("")
    var username = Validated("")
    var email = Validated("")
    var password = Validated("")
    
    var isLoading = false
    
    // MARK: - Initialization
    init(_ scaffold: AuthScaffoldContract) {
        self.logger = scaffold.logger()
        self.navigator = scaffold.navigator()
        self.repository = scaffold.repository()
    }
    
    func completeSetup() {
        isLoading = true
        
        let results = [
            baseURL.validate(
                .trimmingCharacters(in: .whitespacesAndNewlines),
                .hasMinSize(of: 2)
            ),
            
            name.validate(
                .trimmingCharacters(in: .whitespacesAndNewlines),
                .hasMinSize(of: 2)
            ),
            username.validate(
                .trimmingCharacters(in: .whitespacesAndNewlines),
                .hasMinSize(of: 2),
                .isAlphanumeric
            ),
            email.validate(
                .trimmingCharacters(in: .whitespacesAndNewlines),
                .isEmail
            ),
            password.validate(.isPassword) // Don't trim password, could cause confusion.
        ]
        
        // Prevent continuing if not everything is validated.
        guard results.allSatisfy({ $0 }) else { return }
        
        Task {
            do {
                try await repository.setupAdmin(
                    baseURL: baseURL.value,
                    name: name.value,
                    email: email.value,
                    username: username.value,
                    password: password.value
                )
            } catch let error as CoreError {
                navigator.showError(error)
                logger.error("Error creating user:", for: error)
            }
            
            isLoading = false
        }
    }
    
    func navigateBack() {
        navigator.navigateBack()
    }
}
