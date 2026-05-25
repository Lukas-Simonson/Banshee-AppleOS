import Audio
import Business
import Core
import Data
import Foundation
import Logging
import Scaffold
import SharedUI


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
    func databaseManager() -> DatabaseManager {
        do {
            return try DatabaseManager()
        } catch {
            fatalError("Failed to initialize database: \(error)")
        }
    }
    
    @Single
    func player() -> EpisodePlayerContract {
        EpisodePlayer(
            audio: AudioService(),
            logger: Logger(label: "com.bansheeaudio.playback"),
            serverProvider: AppCoordinator.shared,
            remote: CobwebRemotePlayerDataSource(logger: Logger(label: "com.bansheeaudio.playback")),
            local: GRDBLocalPlayerDataSource(
                dbManager: databaseManager(),
                logger: Logger(label: "com.bansheeaudio.playback")
            ),
            localQueue: UserDefaultsLocalQueueDataSource(defaults: defaults()),
            images: ImageCache.shared
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
    
    @Single
    func settings() -> SettingsScaffold {
        SettingsScaffold(app: self)
    }
    
    @Shared
    func episode() -> EpisodeScaffold {
        EpisodeScaffold(app: self)
    }
 
    // MARK: - Coordinators
    
    @Single
    func podcastCoordinator() -> PodcastCoordinator {
        PodcastCoordinator()
    }
    
    @Single
    func settingsCoordinator() -> SettingsCoordinator {
        SettingsCoordinator()
    }
}

extension UserDefaults: @retroactive @unchecked Sendable {}
extension ImageCache: @retroactive ImageDataSourceContract {}
