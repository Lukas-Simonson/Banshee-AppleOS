import Core
import Foundation

struct UserRecord: Codable {
    let id: UUID
    let serverURL: String
    let username: String
    let role: String
}

extension UserRecord {
    init(from user: User) {
        self.id = user.id
        self.serverURL = user.serverURL
        self.username = user.username
        self.role = user.role.rawValue
    }
    
    func toCore() -> User {
        User(
            id: id,
            serverURL: serverURL,
            username: username,
            role: User.Role(rawValue: role) ?? .user
        )
    }
}
