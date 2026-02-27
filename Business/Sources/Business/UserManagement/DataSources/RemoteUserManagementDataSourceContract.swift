import Core

public protocol RemoteUserManagementDataSourceContract: Sendable {
    func registerUser(
        role: User.Role,
        name: String,
        email: String,
        username: String,
        password: String,
        baseURL: String,
        token: String
    ) async throws(CoreError) -> User
}
