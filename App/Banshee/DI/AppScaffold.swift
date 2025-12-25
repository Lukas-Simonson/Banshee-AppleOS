import Audio
import Business
import Core
import Data
import Foundation
import Logging
import Scaffold


final class AppScaffold {
    
    init() {
        LoggingSystem.bootstrap(OSLogHandler.init)
    }
    
    @Single
    func defaults() -> UserDefaults {
        UserDefaults.standard
    }
    
    @Single
    func keychain() -> KeychainService {
        KeychainService(serviceName: "com.bansheeaudio.banshee")
    }
    
    @Single
    func player() -> EpisodePlayerContract {
        EpisodePlayer(
            audio: AudioService(),
            logger: Logger(label: "com.bansheeaudio.playback"),
            serverProvider: AppCoordinator.shared,
            remote: CobwebRemotePlayerDataSource(logger: Logger(label: "com.bansheeaudio.playback"))
        )
    }
    
    // MARK: - Scaffolds
    
    @Single
    func auth() -> AuthScaffold {
        AuthScaffold(app: self)
    }
    
    @Single
    func podcast() -> PodcastScaffold {
        PodcastScaffold(app: self)
    }
    
    @Single
    func audio() -> AudioScaffold {
        AudioScaffold(app: self)
    }
    
    // MARK: - Coordinators
    
    @Single
    func podcastCoordinator() -> PodcastCoordinator {
        PodcastCoordinator()
    }
}

extension UserDefaults: @retroactive @unchecked Sendable {}
