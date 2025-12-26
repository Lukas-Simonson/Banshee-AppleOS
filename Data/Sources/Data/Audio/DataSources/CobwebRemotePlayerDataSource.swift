import Business
import Cobweb
import Core
import Foundation
import Logging

public struct CobwebRemotePlayerDataSource: RemotePlayerDataSourceContract {
    
    private let logger: Logger
    
    public init(logger: Logger) {
        self.logger = logger
    }
    
    public func episode(with id: UUID, baseURL: String, token: String) async throws(RemotePlayerDataSourceError) -> Core.Episode {
        do {
            let response = try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/episodes/\(id)")
                .get()
                .also { logger.info("Making request to /api/episodes/\(id)") }
                .withHeaders(.bearer(token))
                .response()
            
            switch try response.statusCode {
                case 200...299: break
                case 401: throw RemotePlayerDataSourceError.unauthorized
                case 403: throw RemotePlayerDataSourceError.forbidden
                case 404: throw RemotePlayerDataSourceError.notFound
                case 500...599: throw RemotePlayerDataSourceError.serverError
                default: throw RemotePlayerDataSourceError.unexpectedResponse
            }
            
            return try response.body(as: EpisodeDTO.self, JSONDecoder().withISO8601())
                .toCore()
        } catch is Cobweb.URL.URLError {
            throw RemotePlayerDataSourceError.invalidURL
        } catch let error as Cobweb.HTTP.Request.ResponseError {
            logger.error("Failed to get valid response", for: error)
            throw RemotePlayerDataSourceError.invalidResponseFormat
        } catch {
            logger.error("Unexpected error occurred", for: error)
            throw RemotePlayerDataSourceError.networkError
        }
    }

    public func updateProgress(
        episodeId: UUID,
        baseURL: String,
        token: String,
        isCompleted: Bool,
        duration: Int
    ) async throws(RemotePlayerDataSourceError) {
        do {
            let response = try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/episodes/\(episodeId)/progress")
                .post()
                .also { logger.info("Syncing progress for episode \(episodeId): \(duration)s") }
                .withBody(ProgressUpdateRequest(isCompleted: isCompleted, duration: duration))
                .withHeaders(.contentType(value: "application/json"))
                .withHeaders(.bearer(token))
                .response()
            
            switch try response.statusCode {
                case 200...299: break
                case 401: throw RemotePlayerDataSourceError.unauthorized
                case 403: throw RemotePlayerDataSourceError.forbidden
                case 404: throw RemotePlayerDataSourceError.notFound
                case 500...599: throw RemotePlayerDataSourceError.serverError
                default: throw RemotePlayerDataSourceError.unexpectedResponse
            }
        } catch is Cobweb.URL.URLError {
            logger.warning("Failed to sync progress: Invalid URL")
            throw RemotePlayerDataSourceError.invalidURL
        } catch let error as Cobweb.HTTP.Request.ResponseError {
            logger.warning("Failed to sync progress", for: error)
            throw RemotePlayerDataSourceError.invalidResponseFormat
        } catch {
            logger.warning("Failed to sync progress", for: error)
            throw RemotePlayerDataSourceError.networkError
        }
    }
}

extension CobwebRemotePlayerDataSource {
    struct ProgressUpdateRequest: Codable {
        let isCompleted: Bool
        let duration: Int
    }
}
