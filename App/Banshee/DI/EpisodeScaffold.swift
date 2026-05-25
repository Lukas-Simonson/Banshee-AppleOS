import Business
import Core
import Data
import Logging
import Episodes
import Scaffold

final class EpisodeScaffold: EpisodeScaffoldContract {
    
    private let app: AppScaffold
    
    init(app: AppScaffold) {
        self.app = app
    }
    
    func logger() -> Logger {
        var logger = Logger(label: "com.bansheeaudio.banshee.episodes")
        logger.logLevel = .debug
        return logger
    }
    
    func navigator() -> EpisodeNavigationContract {
        app.podcastCoordinator()
    }
    
    func episodeConfigRepository() -> EpisodeConfigRepositoryContract {
        EpisodeConfigRepository(
            logger: logger(),
            serverProvider: AppCoordinator.shared,
            local: GRDBLocalEpisodeConfigDataSource(dbManager: app.databaseManager(), logger: logger()),
            remote: CobwebRemoteEpisodeConfigDataSource(logger: logger())
        )
    }
}
