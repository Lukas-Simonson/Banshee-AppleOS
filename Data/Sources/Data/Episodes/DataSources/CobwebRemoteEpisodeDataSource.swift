import Business
import Cobweb
import Core
import Foundation
import Logging

public struct CobwebRemoteEpisodeDataSource: RemoteEpisodeDataSourceContract {
    
    private var logger: Logger
    
    public init(logger: Logger) {
        self.logger = logger
    }

    public func episodes(with podcastID: UUID, baseURL: String, token: String) async throws(CoreError) -> [Episode] {
        try await CoreError.catchNetwork(performing: "Getting episodes", logger: logger, feature: .episodes) {
            try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/podcasts/\(podcastID)/episodes")
                .get()
                .also { logger.info("Sending request to GET /api/podcasts/\(podcastID)/episodes") }
                .withHeaders(.bearer(token))
                .response()
                .withStatusCoreError(expecting: 200, feature: .podcasts)
                .body(as: [EpisodeDTO].self, JSONDecoder().withISO8601())
                .map { $0.toCore() }
        }
    }
    
}
