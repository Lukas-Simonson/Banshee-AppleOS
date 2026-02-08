import Foundation

public protocol KeyValueStoreContract: Sendable {
    func value<V: Codable>(for key: String) -> V?
    func value<V: Codable>(for key: String, ofType type: V.Type) -> V?
    func store<V: Codable>(_ value: V, for key: String)
    func removeValue(for key: String)
}
