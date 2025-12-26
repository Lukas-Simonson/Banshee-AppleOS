import Core
import Logging

public protocol AudioScaffoldContract {
    func logger() -> Logger
    func player() -> EpisodePlayerContract
    func navigator() -> AudioNavigationContract
}

