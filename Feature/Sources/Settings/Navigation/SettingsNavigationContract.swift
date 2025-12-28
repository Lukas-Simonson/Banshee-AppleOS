import Core

public protocol SettingsNavigationContract: Sendable {
    func showError(_ error: CoreError)
}
