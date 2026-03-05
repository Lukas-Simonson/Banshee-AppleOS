import Core
import Logging

public protocol PodcastScaffoldContract {
    func logger() -> Logger
    
    func navigator() -> PodcastNavigationContract
    
    func podcastRepository() -> PodcastRepositoryContract
    
    func podcastConfigRepository() -> PodcastConfigRepositoryContract
    
    func episodeRepository() -> EpisodeRepositoryContract
    
    func episodeListInteractor() -> EpisodeListInteractorContract
    
    func player() -> EpisodePlayerContract
}
