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
    
    /// Tracks which notices have been shown to prevent duplicate notices.
    private var noticeIDs = Set<UUID>()
    
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
            let repo = scaffold.settings().settingsRepository()
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

extension AppCoordinator: AudioNavigationContract {
    func showError(_ error: CoreError) {
        guard noticeIDs.insert(error.id).inserted else { return }

        notices.queueNotice(ErrorNotice(error: error))
    }
    
    func showAlert(_ alert: CoreAlert) {
        guard noticeIDs.insert(alert.id).inserted else { return }
        
        notices.queueNotice(AlertNotice(alert: alert), urgent: true)
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
