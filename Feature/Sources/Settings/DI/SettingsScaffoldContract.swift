import Core
import Logging

public protocol SettingsScaffoldContract {
    func logger() -> Logger
    func navigator() -> SettingsNavigationContract
    func settingsRepository() -> SettingsRepositoryContract
    func auth() -> AuthRepositoryContract
    func userManagementRepository() -> UserManagementRepositoryContract
}
