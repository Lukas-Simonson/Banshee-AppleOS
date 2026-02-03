import Foundation

public protocol SettingsRepositoryContract: Sendable {
    var settings: Settings { get async }
    var settingsStream: AsyncSequence<Settings, Never> { get }
    
    func update(_ settings: Settings) async throws(CoreError)
}
