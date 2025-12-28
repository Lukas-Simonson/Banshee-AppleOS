import Audio
import Auth
import Core
import Foundation
import Settings
import NoticeMe
import Observation

@Observable
final class AppCoordinator: Sendable {
    static let shared = AppCoordinator()
    
    let scaffold = AppScaffold()
    let notices = NoticeManager()
    
    var mainTab: MainTab = .podcasts
    private(set) var session: AuthSession?
    private(set) var isCheckingSession = true
    
    private(set) var settings: Settings = .default
    
    init() {
        observeSession()
        observeSettings()
    }
    
    private func observeSession() {
        Task {
            for await session in scaffold.auth().repository().sessionStream {
                self.session = session
                isCheckingSession = false
            }
        }
    }
    
    private func observeSettings() {
        Task {
            let repo = scaffold.settings().repository()
            self.settings = await repo.settings
            
            for await settings in repo.settingsStream {
                self.settings = settings
            }
        }
    }
}

extension AppCoordinator {
    enum MainTab {
        case podcasts
        case settings
    }
}

extension AppCoordinator: AuthNavigationContract, AudioNavigationContract, SettingsNavigationContract {
    func navigateHome() {
        // Handled Automatically By Watching Stream
    }

    func showError(_ error: CoreError) {
        notices.queueNotice(ErrorNotice(error: error))
    }
}

extension AppCoordinator: ServerProviderContract {
    var server: String? {
        get async { session?.user.serverURL }
    }
    
    var token: AuthToken? {
        get async { session?.token }
    }
}
