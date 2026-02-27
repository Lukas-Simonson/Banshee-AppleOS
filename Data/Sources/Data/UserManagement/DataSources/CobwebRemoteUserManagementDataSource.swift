import Business
import Cobweb
import Core
import Foundation
import Logging

public struct CobwebRemoteUserManagementDataSource: RemoteUserManagementDataSourceContract {
    private var logger: Logger
    
    public init(logger: Logger) {
        self.logger = logger
    }
    
    public func registerUser(
        role: User.Role,
        name: String,
        email: String,
        username: String,
        password: String,
        baseURL: String,
        token: String
    ) async throws(CoreError) -> User {
        try await CoreError.catchNetwork(performing: "registering user: \(username)", logger: logger, feature: .settings) {
            try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/auth/register")
                .post()
                .also { logger.info("Sending request to POST /api/auth/register") }
                .withHeaders(.bearer(token))
                .withBody([
                    "role": role.rawValue,
                    "name": name,
                    "email": email,
                    "username": username,
                    "password": password,
                ])
                .response()
                .withStatusCoreError(expecting: 201, feature: .settings)
                .body(as: UserDTO.self)
                .toCore(at: baseURL)
        }
    }
}
