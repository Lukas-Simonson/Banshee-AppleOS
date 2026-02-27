import Core

public protocol SettingsNavigationContract: Sendable {
    
    func navigateToCreateUser(for role: User.Role)
    
    func navigateBack()
    
    func showAlert(_ alert: CoreAlert)
    
    func showError(_ error: CoreError)
}
