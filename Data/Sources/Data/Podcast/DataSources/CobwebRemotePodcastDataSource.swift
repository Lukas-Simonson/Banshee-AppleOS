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
            return try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/podcasts")
                .get()
                .also { logger.info("Sending Request to GET /api/podcasts") }
                .withHeaders(.bearer(token))
                .responseBody(as: [PodcastDTO].self)
                .map { $0.toCore() }
        } catch is Cobweb.URL.URLError {
            throw RemotePodcastDataSourceError.invalidURL
        } catch is Cobweb.HTTP.Request.ResponseError {
            throw RemotePodcastDataSourceError.unexpectedResponse
        } catch {
            throw RemotePodcastDataSourceError.unexpected
        }
    }
    
    public func getPodcast(with id: UUID, baseURL: String, token: String) async throws(RemotePodcastDataSourceError) -> Podcast {
        do {
            return try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/podcasts/\(id)")
                .get()
                .also { logger.info("Sending Request to GET /api/podcasts/\(id)") }
                .withHeaders(.bearer(token))
                .responseBody(as: PodcastDTO.self, using: JSONDecoder().withISO8601())
                .toCore()
        } catch let error as Cobweb.URL.URLError {
            logger.error("Created invalid URL", for: error)
            throw RemotePodcastDataSourceError.invalidURL
        } catch let error as Cobweb.HTTP.Request.ResponseError {
            logger.error("Recieved invalid response", for: error)
            throw RemotePodcastDataSourceError.unexpectedResponse
        } catch {
            logger.error("Unexpected error recieved", for: error)
            throw RemotePodcastDataSourceError.unexpected
        }
    }
}
