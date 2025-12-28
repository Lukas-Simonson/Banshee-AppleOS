
public struct Settings: Sendable {
    public var theme: Theme
    
    public init(theme: Theme) {
        self.theme = theme
    }
}

public extension Settings {
    static var `default`: Settings {
        Settings(theme: .violet)
    }
}
