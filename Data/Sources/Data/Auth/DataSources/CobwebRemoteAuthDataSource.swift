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
                .path("/api/auth/login").get()
                .also { logger.info("Sending Request to GET /api/auth/login") }
                .withHeaders(.contentType(value: "application/json"), .basicAuth(username: username, password: password))
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
