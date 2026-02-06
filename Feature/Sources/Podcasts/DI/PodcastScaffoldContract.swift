import Core
import Logging

public protocol PodcastScaffoldContract {
    func logger() -> Logger
    
    func navigator() -> PodcastNavigationContract
    
    func repository() -> PodcastsRepositoryContract
    
    func player() -> EpisodePlayerContract
}
