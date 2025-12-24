import Core
import Foundation

public protocol PodcastNavigationContract {
    func navigateToDetail(for podcast: Podcast)
    
    func navigateBack()
    
    func showError(_ error: LocalizedError)
}
