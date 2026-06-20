import Foundation
import Core

public protocol AuthNavigationContract {

    /// Navigate to main app after successful login
    func navigateHome()
    
    /// Navigate to the server setup screen
    func navigateToSetup()
    
    /// Navigate back to the previous screen
    func navigateBack()

    /// Show error alert
    func showError(_ error: CoreError)
}
