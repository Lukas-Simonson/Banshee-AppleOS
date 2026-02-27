import Core
import Logging
import Observation

@MainActor @Observable
final class SettingsVM {
    // MARK: - Dependencies
    private let logger: Logger
    private let navigator: SettingsNavigationContract
    private let repository: SettingsRepositoryContract
    private let auth: AuthRepositoryContract

    // MARK: - State
    private(set) var settings: Settings
    
    // MARK: - Initialization
    init(_ scaffold: SettingsScaffoldContract) {
        self.logger = scaffold.logger()
        self.navigator = scaffold.navigator()
        self.repository = scaffold.settingsRepository()
        self.auth = scaffold.auth()

        settings = .default
        observeSettings()
    }
    
    func updateSettings(_ newValue: Settings) {
        Task {
            do {
                logger.info("Updating app settings: \(newValue)")
                try await repository.update(newValue)
            } catch let error as CoreError {
                navigator.showError(error)
            }
        }
    }
    
    func navigateToCreateUser(_ role: User.Role) {
        navigator.navigateToCreateUser(for: role)
    }

    func logout() {
        Task {
            do {
                try await auth.logout()
            } catch let error as CoreError {
                navigator.showError(error)
            }
        }
    }

    // MARK: - Private Methods
    private func observeSettings() {
        Task { [weak self] in
            guard let stream = self?.repository.settingsStream else { return }
            
            for await settings in stream {
                guard let self else { break }
                self.settings = settings
            }
        }
    }
}
