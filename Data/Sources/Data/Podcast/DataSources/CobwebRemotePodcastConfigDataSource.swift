import Business
import Cobweb
import Core
import Foundation
import Logging

public struct CobwebRemotePodcastConfigDataSource: RemotePodcastConfigDataSourceContract {
    
    private var logger: Logger
    
    public init(logger: Logger) {
        self.logger = logger
    }
    
    public func getConfig(with podcastID: UUID, baseURL: String, token: String) async throws(CoreError) -> (Podcast, PodcastConfig) {
        try await CoreError.catchNetwork(performing: "getting config for podcast with id: \(podcastID)", logger: logger, feature: .podcasts) {
            try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/podcasts/\(podcastID)")
                .query(.item(key: "config", value: "include"), .item(key: "includeEpisodes", value: false))
                .get()
                .also { logger.info("Sending request to GET /api/podcasts/\(podcastID)") }
                .withHeaders(.bearer(token))
                .response()
                .withStatusCoreError(expecting: 200, feature: .podcasts)
                .body(as: PodcastDTO.self)
                .toCoreWithConfig()
        }
    }
    
    public func postConfig(_ config: PodcastConfig, baseURL: String, token: String) async throws(CoreError) {
        try await CoreError.catchNetwork(performing: "posting config for podcast with id: \(config.podcastID)", logger: logger, feature: .podcasts) {
            try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/podcasts/\(config.podcastID)/config")
                .put()
                .also { logger.info("Sending request to PUT /api/podcasts/\(config.podcastID)/config") }
                .withHeaders(.bearer(token), .contentType(value: "application/json"))
                .withBody(config.toDTO())
                .response()
                .withStatusCoreError(expecting: 202, feature: .podcasts)
        }
    }
}
