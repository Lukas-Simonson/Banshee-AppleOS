import Core
import Foundation
import Logging
import Overflow

public final class SettingsRepository: SettingsRepositoryContract {
    
    // MARK: - Private Properties
    private let logger: Logger
    private let local: LocalSettingsDataSourceContract
    
    private let settingsFlow = MutableStateFlow(initial: Settings.default)
    
    // MARK: - Shared State
    public var settings: Settings {
        get async { await settingsFlow.value }
    }
    
    public var settingsStream: AsyncSequence<Settings, Never> {
        settingsFlow
    }
    
    public init(
        logger: Logger,
        local: LocalSettingsDataSourceContract
    ) {
        self.logger = logger
        self.local = local
        self.load()
    }
    
    // MARK: - Settings Management
    public func update(_ settings: Settings) async throws(SettingsRepositoryError) {
        do {
            logger.info("Recieved request to update settings: \(settings)")
            try await local.saveSettings(settings)
            logger.info("Emitting new settings: \(settings)")
            await settingsFlow.emit(settings)
        } catch {
            logger.warning("Unable to save settings locally", for: error)
            throw SettingsRepositoryError.unableToSave
        }
    }
    
    private func load() {
        Task { [self] in
            do {
                try await settingsFlow.emit(local.readSettings())
            } catch {
                logger.warning("Unable to load saved settings, falling back to default", for: error)
            }
        }
    }
}
