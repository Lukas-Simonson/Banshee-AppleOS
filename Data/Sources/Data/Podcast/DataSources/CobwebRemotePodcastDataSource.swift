import Business
import Cobweb
import Core
import Foundation
import Logging

public struct CobwebRemotePodcastDataSource: RemotePodcastDataSourceContract {
    
    private var logger: Logger
    
    public init(logger: Logger) {
        self.logger = logger
    }
    
    public func getPodcasts(baseURL: String, token: String) async throws(RemotePodcastDataSourceError) -> [Podcast] {
        do {
            let response = try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/podcasts")
                .get()
                .also { logger.info("Sending Request to GET /api/podcasts") }
                .withHeaders(.bearer(token))
                .response()
            
            switch try response.statusCode {
                case 200...299: break
                case 401: throw RemotePodcastDataSourceError.unauthorized
                case 403: throw RemotePodcastDataSourceError.forbidden
                case 404: throw RemotePodcastDataSourceError.notFound
                case 429: throw RemotePodcastDataSourceError.rateLimited
                case 500...599: throw RemotePodcastDataSourceError.serverError
                default: throw RemotePodcastDataSourceError.unexpectedResponse
            }
            
            return try response.body(as: [PodcastDTO].self).map { $0.toCore() }
        } catch is Cobweb.URL.URLError {
            throw RemotePodcastDataSourceError.invalidURL
        } catch let error as Cobweb.HTTP.Request.ResponseError {
            logger.error("Failed to get podcasts", for: error)
            throw RemotePodcastDataSourceError.invalidResponseFormat
        } catch {
            logger.error("Unexpected error getting podcasts", for: error)
            throw RemotePodcastDataSourceError.unexpected
        }
    }
    
    public func getPodcast(with id: UUID, baseURL: String, token: String) async throws(RemotePodcastDataSourceError) -> Podcast {
        do {
            let response = try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/podcasts/\(id)")
                .query(.item(key: "includeEpisodeProgress", value: true))
                .get()
                .also { logger.info("Sending Request to GET /api/podcasts/\(id)") }
                .withHeaders(.bearer(token))
                .response()
            
            switch try response.statusCode {
                case 200...299: break
                case 401: throw RemotePodcastDataSourceError.unauthorized
                case 403: throw RemotePodcastDataSourceError.forbidden
                case 404: throw RemotePodcastDataSourceError.notFound
                case 500...599: throw RemotePodcastDataSourceError.serverError
                default: throw RemotePodcastDataSourceError.unexpectedResponse
            }
            
            return try response.body(as: PodcastDTO.self, JSONDecoder().withISO8601()).toCore()            
        } catch is Cobweb.URL.URLError {
            logger.error("Created invalid URL")
            throw RemotePodcastDataSourceError.invalidURL
        } catch let error as Cobweb.HTTP.Request.ResponseError {
            logger.error("Received invalid response", for: error)
            throw RemotePodcastDataSourceError.invalidResponseFormat
        } catch {
            logger.error("Unexpected error received", for: error)
            throw RemotePodcastDataSourceError.unexpected
        }
    }
}
