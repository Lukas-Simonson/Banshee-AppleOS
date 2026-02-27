import Core

public protocol SettingsNavigationContract: Sendable {
    
    func navigateToCreateUser(for role: User.Role)
    
    func navigateBack()
    
    func showError(_ error: CoreError)
}
