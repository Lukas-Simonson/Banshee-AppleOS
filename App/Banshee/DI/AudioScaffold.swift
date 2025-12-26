import Audio
import Business
import Core
import Data
import Logging
import Podcasts
import Scaffold

final class AudioScaffold: AudioScaffoldContract {
    
    private var app: AppScaffold
    
    init(app: AppScaffold) {
        self.app = app
    }
    
    func logger() -> Logging.Logger {
        var logger = Logger(label: "com.bansheeaudio.banshee.audio")
        logger.logLevel = .debug
        return logger
    }
    
    func player() -> EpisodePlayerContract {
        app.player()
    }
    
    func navigator() -> AudioNavigationContract {
        AppCoordinator.shared
    }
}
