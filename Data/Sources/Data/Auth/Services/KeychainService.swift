import Foundation
import Security

/// Service for secure Keychain storage
public final class KeychainService: Sendable {
    
    private let serviceName: String
    
    public init(serviceName: String) {
        self.serviceName = serviceName
    }
    
    public func set(key: String, value: String) throws(KeychainError) {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unableToSave(status: status)
        }
    }
    
    public func get(key: String) throws(KeychainError) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status != errSecItemNotFound else {
            return nil
        }
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.unableToRetrieve(status: status)
        }
        
        return value
    }
    
    public func delete(key: String) throws(KeychainError) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unableToDelete(status: status)
        }
    }
    
    public enum KeychainError: Error {
        case unableToSave(status: OSStatus)
        case unableToRetrieve(status: OSStatus)
        case unableToDelete(status: OSStatus)
    }
}
