import Foundation

public protocol SettingsRepositoryContract: Sendable {
    var settings: Settings { get async }
    var settingsStream: AsyncSequence<Settings, Never> { get }
    
    func update(_ settings: Settings) async throws(SettingsRepositoryError)
}

public enum SettingsRepositoryError: CoreError {
    case unableToSave
    
    public var errorCode: UInt16 {
        switch self {
            case .unableToSave: 401
        }
    }
    
    public var localizeableKey: LocalizedStringResource {
        switch self {
            case .unableToSave: "error.settings.unableToSave"
        }
    }
    
    public var logMessage: String {
        switch self {
            case .unableToSave:
                "Unable to save settings value locally"
        }
    }
}
