import Business
import Core
import Data
import Logging
import Scaffold
import Settings

final class SettingsScaffold: SettingsScaffoldContract {
    
    private var app: AppScaffold
    
    init(app: AppScaffold) {
        self.app = app
    }
    
    func logger() -> Logger {
        var logger = Logger(label: "com.bansheeaudio.banshee.settings")
        logger.logLevel = .debug
        return logger
    }
    
    func navigator() -> SettingsNavigationContract {
        app.settingsCoordinator()
    }

    @Single
    func settingsRepository() -> SettingsRepositoryContract {
        SettingsRepository(
            logger: logger(),
            local: UserDefaultsLocalSettingsDataSource(
                logger: logger(),
                defaults: app.defaults()
            )
        )
    }

    func auth() -> any AuthRepositoryContract {
        app.auth().repository()
    }
    
    func userManagementRepository() -> any UserManagementRepositoryContract {
        UserManagementRepository(
            logger: logger(),
            serverProvider: AppCoordinator.shared,
            remote: CobwebRemoteUserManagementDataSource(logger: logger())
        )
    }
}
