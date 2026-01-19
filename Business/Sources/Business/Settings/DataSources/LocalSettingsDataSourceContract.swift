import Core

public protocol LocalSettingsDataSourceContract: Sendable {
    func saveSettings(_ settings: Settings) async throws(CoreError)
    func readSettings() async throws(CoreError) -> Settings
}
