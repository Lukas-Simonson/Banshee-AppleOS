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
    
    public func episode(with id: UUID, baseURL: String, token: String) async throws -> Core.Episode {
        do {
            return try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/episodes/\(id)")
                .get()
                .also { logger.info("Making request to /api/episodes/\(id)") }
                .withHeaders(.bearer(token))
                .responseBody(as: EpisodeDTO.self, using: JSONDecoder().withISO8601())
                .toCore()
        } catch is Cobweb.URL.URLError {
            throw RemotePodcastDataSourceError.invalidURL
        } catch let error as Cobweb.HTTP.Request.ResponseError {
            logger.error("Failed to get valid response", for: error)
            throw RemotePodcastDataSourceError.unexpectedResponse
        } catch {
            throw RemotePodcastDataSourceError.unexpected
        }
    }
}
