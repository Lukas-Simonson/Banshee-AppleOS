import Core
import Foundation

struct UserRecord: Codable {
    let id: UUID
    let serverURL: String
    let name: String
    let email: String
    let username: String
    let role: String
}

extension UserRecord {
    init(from user: User) {
        self.id = user.id
        self.serverURL = user.serverURL
        self.name = user.name
        self.email = user.email
        self.username = user.username
        self.role = user.role.rawValue
    }
    
    func toCore() -> User {
        User(
            id: id,
            serverURL: serverURL,
            name: name,
            email: email,
            username: username,
            role: User.Role(rawValue: role) ?? .user
        )
    }
}
