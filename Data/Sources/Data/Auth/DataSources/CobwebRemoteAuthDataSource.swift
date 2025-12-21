import Business
import Cobweb
import Core
import Foundation

struct CobwebRemoteAuthDataSource: RemoteAuthDataSourceContract {
    
    func login(baseURL: String, username: String, password: String) async throws(RemoteAuthDataSourceError) -> AuthSession {
        do {
            let user = try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/auth").post()
                .withBody(["username": username, "password": password])
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
    
    func verifyServer(baseURL: String) async throws(RemoteAuthDataSourceError) {
        do {
            try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/info")
                .get()
        } catch let error as Cobweb.URL.URLError {
            throw RemoteAuthDataSourceError.urlError
        }
    }
}
