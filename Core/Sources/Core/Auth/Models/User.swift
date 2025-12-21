import Foundation

public struct User: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let serverURL: String
    public let username: String
    public let role: Role
    
    public init(id: UUID, serverURL: String, username: String, role: Role) {
        self.id = id
        self.serverURL = serverURL
        self.username = username
        self.role = role
    }
}

extension User {
    public enum Role: String, Sendable {
        case user
        case admin
    }
}
