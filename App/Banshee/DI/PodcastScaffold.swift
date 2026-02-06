import Business
import Core
import Data
import Logging
import Podcasts
import Scaffold

final class PodcastScaffold: PodcastScaffoldContract {
    
    private var app: AppScaffold
    
    init(app: AppScaffold) {
        self.app = app
    }
    
    func logger() -> Logger {
        var logger = Logger(label: "com.bansheeaudio.banshee.podcasts")
        logger.logLevel = .debug
        return logger
    }
    
    func navigator() -> PodcastNavigationContract {
        app.podcastCoordinator()
    }

    func podcastRepository() -> PodcastRepositoryContract {
        PodcastRepository(
            logger: logger(),
            serverProvider: AppCoordinator.shared,
            local: GRDBLocalPodcastDataSource(dbManager: app.databaseManager(), logger: logger()),
            remote: CobwebRemotePodcastDataSource(logger: logger())
        )
    }
    
    func podcastConfigRepository() -> PodcastConfigRepositoryContract {
        PodcastConfigRepository(
            logger: logger(),
            serverProvider: AppCoordinator.shared,
            local: GRDBLocalPodcastConfigDataSource(dbManager: app.databaseManager(), logger: logger()),
            remote: CobwebRemotePodcastConfigDataSource(logger: logger())
        )
    }
    
    func episodeRepository() -> EpisodeRepositoryContract {
        EpisodeRepository(
            logger: logger(),
            serverProvider: AppCoordinator.shared,
            local: GRDBLocalEpisodeDataSource(dbManager: app.databaseManager(), logger: logger()),
            remote: CobwebRemoteEpisodeDataSource(logger: logger())
        )
    }
    
    func player() -> any EpisodePlayerContract {
        app.player()
    }
}
