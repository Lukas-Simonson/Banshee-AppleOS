import Foundation

public protocol AuthNavigationContract {
    
    /// Navigate to main app after successful login
    func navigateHome()
    
    /// Show error alert
    func showError(_ error: LocalizedError)
}
