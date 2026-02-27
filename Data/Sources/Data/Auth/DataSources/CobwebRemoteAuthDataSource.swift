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
        do {
            let response = try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/auth/login").get()
                .also { logger.info("Sending Request to GET /api/auth/login") }
                .withHeaders(.contentType(value: "application/json"), .basicAuth(username: username, password: password))
                .response()

            switch try response.statusCode {
                case 200: break // Expected Response
                case 401: throw CoreError.invalidCredentials
                case 500...599: throw CoreError.serverError(layer: .data, feature: .auth)
                default: throw CoreError.unexpectedResponse(
                    layer: .data,
                    feature: .auth,
                    code: try response.statusCode
                )
            }

            let user = try response.body(as: UserDTO.self)

            return AuthSession(
                user: user.toCore(at: baseURL),
                // The user.token SHOULD always be present.
                token: AuthToken(token: user.token!, createdAt: .now)
            )
        } catch let error as CoreError {
            throw error
        } catch let error as Cobweb.URL.URLError {
            logger.error("Unable to create URL", for: error)
            throw CoreError.urlError(layer: .data, feature: .auth)
        } catch let error as Cobweb.HTTP.Request.ResponseError {
            logger.error("Login failed with response error", for: error)
            throw CoreError.invalidResponseFormat(layer: .data, feature: .auth)
        } catch {
            logger.error("Unknown error found during login", for: error)
            throw CoreError.unexpected(layer: .data, feature: .auth)
        }
    }
    
    public func verifyServer(baseURL: String) async throws(CoreError) {
        do {
            let response = try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/info")
                .also { logger.info("Sending Request to GET /api/info") }
                .get()
                .response()
            
            switch try response.statusCode {
                case 200: break
                case 500...599: throw CoreError.serverError(layer: .data, feature: .auth)
                default: throw CoreError.unexpectedResponse(
                    layer: .data,
                    feature: .auth,
                    code: try response.statusCode
                )
            }
        } catch let error as CoreError {
            throw error
        } catch let error as Cobweb.URL.URLError {
            logger.error("Unable to create URL", for: error)
            throw CoreError.urlError(layer: .data, feature: .auth)
        } catch let error as Cobweb.HTTP.Request.ResponseError {
            logger.error("Server Verification failed with response error", for: error)
            throw CoreError.invalidResponseFormat(layer: .data, feature: .auth)
        } catch {
            logger.error("Unknown error found during server verification", for: error)
            throw CoreError.unexpected(layer: .data, feature: .auth)
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
