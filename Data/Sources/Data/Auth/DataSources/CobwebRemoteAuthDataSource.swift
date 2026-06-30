import Business
import Cobweb
import Core
import Foundation
import Logging

public struct CobwebRemoteAuthDataSource: RemoteAuthDataSourceContract {

    private let logger: Logger
    
    public init(logger: Logger) {
        self.logger = logger
    }
    
    public func login(baseURL: String, username: String, password: String) async throws(CoreError) -> AuthSession {
        try await CoreError.catchNetwork(performing: "logging in user", logger: logger, feature: .auth) {
            let user = try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/auth/login").post()
                .also { logger.info("Sending Request to GET /api/auth/login") }
                .withHeaders(.basicAuth(username: username, password: password))
                .response()
                .verifyStatusCode(isNot: 401, orThrow: CoreError.invalidCredentials)
                .withStatusCoreError(expecting: 200, feature: .auth)
                .body(as: UserDTO.self)
            
            return AuthSession(
                user: user.toCore(at: baseURL),
                token: AuthToken(token: user.token!, createdAt: .now)
            )
        }
    }
    
    public func setupAdmin(baseURL: String, name: String, email: String, username: String, password: String) async throws(Core.CoreError) -> AuthSession {
        try await CoreError.catchNetwork(performing: "setting up initial admin account", logger: logger, feature: .auth) {
            let user = try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/auth/setup").post()
                .also { logger.info("Sending Request to POST /api/auth/setup") }
                .withHeaders(.contentType(value: "application/json"))
                .withBody([
                    "role": "admin",
                    "name": name,
                    "email": email,
                    "username": username,
                    "password": password,
                ])
                .response()
                .withStatusCoreError(expecting: 201, feature: .settings)
                .body(as: UserDTO.self)
            
            return AuthSession(
                user: user.toCore(at: baseURL),
                token: AuthToken(token: user.token!, createdAt: .now)
            )
        }
    }
    
    public func verifyServer(baseURL: String) async throws(CoreError) {
        try await CoreError.catchNetwork(performing: "verifying server status", logger: logger, feature: .auth) {
            try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/info")
                .also { logger.info("Sending Request to GET /api/info") }
                .get()
                .response()
                .withStatusCoreError(expecting: 200, feature: .auth)
        }
    }
}

extension CoreError {
    static var invalidCredentials: CoreError {
        CoreError(
            layer: .data,
            feature: .auth,
            code: 50,
            localizedKey: "error.network.auth.invalidCredentials",
            logMessage: "Invalid credentials provided to server."
        )
    }
}
