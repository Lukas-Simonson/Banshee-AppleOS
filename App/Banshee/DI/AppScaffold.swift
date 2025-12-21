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
    func auth() -> AuthScaffold {
        AuthScaffold(app: self)
    }
}

extension UserDefaults: @retroactive @unchecked Sendable {}
