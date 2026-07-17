import Core
import Foundation

public protocol PodcastNavigationContract {
    func navigateToDetail(for podcast: Podcast)
    
    func navigateToEditConfig(for podcast: Podcast)
    
    func navigateToEditConfig(for episode: Episode)
    
    func navigateToBulkEditConfig(episodeIDs: Set<UUID>)

    func navigateBack()

    func showError(_ error: CoreError)
}
