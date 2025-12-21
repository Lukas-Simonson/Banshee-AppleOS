import Core
import Foundation

struct UserDTO: Codable {
    let id: UUID
    let role: String
    let username: String
    let token: String
}

extension UserDTO {
    func toCore(at url: String) -> User {
        User(
            id: id,
            serverURL: url,
            username: username,
            role: User.Role(rawValue: role) ?? .user
        )
    }
}
