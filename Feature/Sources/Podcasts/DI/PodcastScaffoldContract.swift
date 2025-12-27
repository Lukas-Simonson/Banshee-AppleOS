import Core
import Logging

public protocol PodcastScaffoldContract {
    func logger() -> Logger
    
    func navigator() -> PodcastNavigationContract
    
    func repository() -> PodcastRepositoryContract
    
    func player() -> EpisodePlayerContract
}
