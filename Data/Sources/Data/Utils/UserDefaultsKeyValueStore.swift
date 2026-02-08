import Core
import Foundation

public final class UserDefaultsKeyValueStore: KeyValueStoreContract, @unchecked Sendable {
    
    private var defaults: UserDefaults
    
    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }
    
    public func value<V: Codable>(for key: String) -> V? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(V.self, from: data)
    }
    
    public func value<V: Codable>(for key: String, ofType type: V.Type) -> V? {
        return value(for: key)
    }
    
    public func store<V: Codable>(_ value: V, for key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }
    
    public func removeValue(for key: String) {
        defaults.removeObject(forKey: key)
    }
}
