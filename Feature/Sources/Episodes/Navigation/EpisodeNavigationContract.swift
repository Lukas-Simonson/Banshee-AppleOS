import Core
import Foundation

public protocol EpisodeNavigationContract {
    func navigateBack()
    
    func showError(_ error: CoreError)
}
