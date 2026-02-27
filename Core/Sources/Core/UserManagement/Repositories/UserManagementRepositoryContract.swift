import Foundation

public protocol UserManagementRepositoryContract: Sendable {
    func registerUser(role: User.Role, name: String, email: String, username: String, password: String) async throws(CoreError) -> User
}
