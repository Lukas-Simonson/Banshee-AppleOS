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

    @Single
    func databaseManager() -> DatabaseManager {
        do {
            return try DatabaseManager()
        } catch {
            fatalError("Failed to initialize database: \(error)")
        }
    }

    @Single
    func localDataSource() -> LocalPodcastDataSourceContract {
        GRDBLocalPodcastDataSource(
            dbManager: databaseManager(),
            logger: logger()
        )
    }

    @Single
    func repository() -> PodcastRepositoryContract {
        PodcastRepository(
            logger: logger(),
            serverProvider: AppCoordinator.shared,
            remote: CobwebRemotePodcastDataSource(logger: logger()),
            local: localDataSource()
        )
    }
    
    func player() -> any EpisodePlayerContract {
        app.player()
    }
}
