import Core
import Logging

public protocol SettingsScaffoldContract {
    func logger() -> Logger
    func navigator() -> SettingsNavigationContract
    func repository() -> SettingsRepositoryContract
}
