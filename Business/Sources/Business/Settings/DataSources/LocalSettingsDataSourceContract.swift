import Core

public protocol LocalSettingsDataSourceContract: Sendable {
    func saveSettings(_ settings: Settings) async throws(LocalSettingsDataSourceError)
    func readSettings() async throws(LocalSettingsDataSourceError) -> Settings
}

public enum LocalSettingsDataSourceError: String, Error {
    case empty = "No settings values have been saved"
}
