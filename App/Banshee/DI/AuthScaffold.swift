import Auth
import Business
import Core
import Data
import Logging
import Scaffold

final class AuthScaffold: AuthScaffoldContract {
    
    private var app: AppScaffold
    
    init(app: AppScaffold) {
        self.app = app
    }
    
    func logger() -> Logger {
        var logger = Logger(label: "com.bansheeaudio.banshee.auth")
        logger.logLevel = .debug
        return logger
    }
    
    func navigator() -> AuthNavigationContract {
        AppCoordinator.shared
    }
    
    @Single
    func repository() -> AuthRepositoryContract {
        AuthRepository(
            local: LocalAuthDataSource(
                keychain: app.keychain(),
                defaults: app.defaults(),
                logger: logger()
            ),
            remote: CobwebRemoteAuthDataSource(
                logger: logger()
            ),
            logger: logger()
        )
    }
}
