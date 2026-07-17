import Business
import Cobweb
import Core
import Foundation
import Logging

public struct CobwebRemoteEpisodeConfigDataSource: RemoteEpisodeConfigDataSourceContract {
    
    private var logger: Logger
    
    public init(logger: Logger) {
        self.logger = logger
    }
    
    public func getConfig(with episodeID: UUID, baseURL: String, token: String) async throws(CoreError) -> (Episode, EpisodeConfig) {
        try await CoreError.catchNetwork(performing: "getting config for episode with id: \(episodeID)", logger: logger, feature: .episodes) {
            try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/episodes/\(episodeID)")
                .query(.item(key: "config", value: "include"))
                .get()
                .also { logger.info("Sending request to GET /api/episodes/\(episodeID)") }
                .withHeaders(.bearer(token))
                .response()
                .withStatusCoreError(expecting: 200, feature: .podcasts)
                .body(as: EpisodeDTO.self, JSONDecoder().withISO8601())
                .toCoreWithConfig()
        }
    }
    
    public func postConfig(_ config: EpisodeConfig, baseURL: String, token: String) async throws(CoreError) {
        try await CoreError.catchNetwork(performing: "posting config for episode with id: \(config.episodeID)", logger: logger, feature: .episodes) {
            try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/episodes/\(config.episodeID)/config")
                .put()
                .also { logger.info("Sending request to PUT /api/podcasts/\(config.episodeID)/config") }
                .withHeaders(.bearer(token), .contentType(value: "application/json"))
                .withBody(config.toDTO())
                .response()
                .withStatusCoreError(expecting: 202, feature: .episodes)
        }
    }
    
    public func postBulkConfig(_ config: BulkEpisodeConfig, baseURL: String, token: String) async throws(CoreError) -> [Episode] {
        try await CoreError.catchNetwork(performing: "posting bulk episode config", logger: logger, feature: .episodes) {
            try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/episodes/configs")
                .put()
                .also { logger.info("Sending request to PUT /api/episodes/configs") }
                .withHeaders(.bearer(token), .contentType(value: "application/json"))
                .withBody(config.toDTO())
                .response()
                .withStatusCoreError(expecting: 202, feature: .episodes)
                .body(as: [EpisodeDTO].self, JSONDecoder().withISO8601())
                .map { $0.toCore() }
        }
    }
}
