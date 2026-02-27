import Core
import Foundation

struct UserDTO: Codable {
    let id: UUID
    let name: String
    let email: String
    let username: String
    let role: String
    let token: String?
}

extension UserDTO {
    func toCore(at url: String) -> User {
        User(
            id: id,
            serverURL: url,
            name: name,
            email: email,
            username: username,
            role: User.Role(rawValue: role) ?? .user
        )
    }
}
