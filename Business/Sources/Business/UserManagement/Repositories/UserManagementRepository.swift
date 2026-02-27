import Core
import Foundation
import Logging

public final class UserManagementRepository: UserManagementRepositoryContract {
    
    // MARK: - Private Properties
    private let logger: Logger
    private let serverProvider: ServerProviderContract
    private let remote: RemoteUserManagementDataSourceContract
    
    public init(logger: Logger, serverProvider: ServerProviderContract, remote: RemoteUserManagementDataSourceContract) {
        self.logger = logger
        self.serverProvider = serverProvider
        self.remote = remote
    }
    
    public func registerUser(
        role: User.Role,
        name: String,
        email: String,
        username: String,
        password: String
    ) async throws(CoreError) -> User {
        
        guard let token = await serverProvider.token?.token,
              let server = await serverProvider.server
        else { throw CoreError.notAuthenticated(layer: .business, feature: .settings) }
        
        return try await remote.registerUser(
            role: role,
            name: name,
            email: email,
            username: username,
            password: password,
            baseURL: server,
            token: token
        )
    }
}
