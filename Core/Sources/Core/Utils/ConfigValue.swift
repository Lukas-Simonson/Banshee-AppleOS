import Foundation

public enum ConfigValue<T> {
    case ignore
    case nullify
    case replace(T)
}

extension ConfigValue {
    public var value: T? {
        switch self {
            case .ignore, .nullify: nil
            case .replace(let t): t
        }
    }
}

extension ConfigValue: Equatable where T: Equatable {
    
}

extension ConfigValue: Hashable where T: Hashable {
    
}

extension ConfigValue: Sendable where T: Sendable {
    
}
