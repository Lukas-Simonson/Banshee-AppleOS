import Core
import Logging
import Observation
import SharedUI

@MainActor @Observable
final class UserRegistrationVM {
    // MARK: - Dependencies
    private let logger: Logger
    private let navigator: SettingsNavigationContract
    private let repository: UserManagementRepositoryContract
    
    // MARK: - State
    let role: User.Role
    var name = Validated("")
    var username = Validated("")
    var email = Validated("")
    var password = Validated("")
    
    var isLoading = false
    
    // MARK: - Initialization
    init(_ scaffold: SettingsScaffoldContract, for role: User.Role) {
        self.role = role
        self.logger = scaffold.logger()
        self.navigator = scaffold.navigator()
        self.repository = scaffold.userManagementRepository()
    }
    
    func createUser() {
        isLoading = true
        
        let results = [
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
                _ = try await repository.registerUser(
                    role: role,
                    name: name.value,
                    email: email.value,
                    username: username.value,
                    password: password.value
                )
                navigator.navigateBack()
                navigator.showAlert(
                    CoreAlert(
                        title: "Created \(role.rawValue.capitalized)",
                        message: "Successfully create a new \(role.rawValue).",
                        actions: CoreAlert.Action(
                            title: "Okay",
                            action: { }
                        )
                    )
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
