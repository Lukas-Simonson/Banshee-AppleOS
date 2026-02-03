import Business
import Core
import Foundation
import Logging

public final class UserDefaultsLocalSettingsDataSource: LocalSettingsDataSourceContract, @unchecked Sendable {
    private let logger: Logger
    private let defaults: UserDefaults
    
    private var theme: Settings.Theme? {
        get {
            if let value = defaults.string(forKey: Keys.theme) {
                return Settings.Theme(rawValue: value)
            }
            return nil
        }
        set { defaults.set(newValue?.rawValue, forKey: Keys.theme) }
    }
    
    public init(logger: Logger, defaults: UserDefaults) {
        self.logger = logger
        self.defaults = defaults
    }
    
    public func saveSettings(_ settings: Settings) async throws(CoreError) {
        self.theme = settings.theme
    }
    
    public func readSettings() async throws(CoreError) -> Settings {
        guard let theme else { throw CoreError.emptySettings }
        return Settings(theme: theme)
    }
    
    private enum Keys {
        static let theme = "com.bansheeaudio.settings.theme"
    }
}

extension CoreError {
    static var emptySettings: CoreError {
        CoreError(
            layer: .data,
            feature: .settings,
            code: 50,
            localizedKey: "error.data.settings.emptySettings",
            logMessage: "No saved settings were found."
        )
    }
}
