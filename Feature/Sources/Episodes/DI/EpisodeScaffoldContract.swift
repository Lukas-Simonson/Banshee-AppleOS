import Core
import Logging

public protocol EpisodeScaffoldContract {
    func logger() -> Logger
    
    func navigator() -> EpisodeNavigationContract
    
    func episodeConfigRepository() -> EpisodeConfigRepositoryContract
}
