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
    
    public func login(baseURL: String, username: String, password: String) async throws(RemoteAuthDataSourceError) -> AuthSession {
        do {
            let user = try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/auth/login").post()
                .also { logger.info("Sending Request to POST /api/auth/login") }
                .withBody(["username": username, "password": password])
                .withHeaders(.contentType(value: "application/json"))
                .response()
                .verifyStatusCode(is: 200, orThrow: RemoteAuthDataSourceError.unexpectedResponse)
                .body(as: UserDTO.self)
            
            return AuthSession(
                user: user.toCore(at: baseURL),
                token: AuthToken(token: user.token, createdAt: .now)
            )
        } catch let error as Cobweb.URL.URLError {
            throw RemoteAuthDataSourceError.urlError
        } catch let error as RemoteAuthDataSourceError {
            throw error
        } catch {
            throw RemoteAuthDataSourceError.unknownError
        }
    }
    
    public func verifyServer(baseURL: String) async throws(RemoteAuthDataSourceError) {
        do {
            try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/info")
                .also { logger.info("Sending Request to GET /api/info") }
                .get()
                .response()
                .verifyStatusCode(is: 200, orThrow: RemoteAuthDataSourceError.unexpectedResponse)
        } catch let error as RemoteAuthDataSourceError {
            throw error
        } catch let error as Cobweb.URL.URLError {
            throw RemoteAuthDataSourceError.urlError
        } catch let error as Cobweb.HTTP.Request.ResponseError {
            throw RemoteAuthDataSourceError.unexpectedResponse
        } catch {
            throw RemoteAuthDataSourceError.unknownError
        }
    }
}
