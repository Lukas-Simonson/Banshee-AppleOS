import Core
import Logging
import Observation

@MainActor @Observable
final class SettingsVM {
    // MARK: - Dependencies
    private let logger: Logger
    private let navigator: SettingsNavigationContract
    private let repository: SettingsRepositoryContract
    
    // MARK: - State
    private(set) var settings: Settings
    
    // MARK: - Initialization
    init(_ scaffold: SettingsScaffoldContract) {
        self.logger = scaffold.logger()
        self.navigator = scaffold.navigator()
        self.repository = scaffold.repository()
        
        settings = .default
        observeSettings()
    }
    
    func updateSettings(_ newValue: Settings) {
        Task {
            do {
                logger.info("Updating app settings: \(newValue)")
                try await repository.update(newValue)
            } catch let error as SettingsRepositoryError {
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
