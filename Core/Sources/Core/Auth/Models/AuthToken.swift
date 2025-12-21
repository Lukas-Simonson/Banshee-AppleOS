import Foundation

public struct AuthToken: Equatable, Sendable {
    public let token: String
    public let createdAt: Date
    
    public init(token: String, createdAt: Date = .now) {
        self.token = token
        self.createdAt = createdAt
    }
}
