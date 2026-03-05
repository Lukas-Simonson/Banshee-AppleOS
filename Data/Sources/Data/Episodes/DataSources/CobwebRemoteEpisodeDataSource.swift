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
    
    public func updateEpisodeCompletion(with id: UUID, isComplete: Bool, baseURL: String, token: String) async throws(CoreError) {
        try await CoreError.catchNetwork(performing: "Syncing episode progress", logger: logger, feature: .audio) {
            if isComplete {
                try await Cobweb.URL.using(baseURL: baseURL)
                    .path("/api/episodes/\(id)/progress")
                    .put()
                    .also { logger.info("Syncing progress for episode \(id), isComplete: \(isComplete)") }
                    .withBody(["isCompleted": isComplete])
                    .withHeaders(.contentType(value: "application/json"), .bearer(token))
                    .response()
                    .withStatusCoreError(expecting: 202, feature: .audio)
            } else {
                try await Cobweb.URL.using(baseURL: baseURL)
                    .path("/api/episodes/\(id)/progress")
                    .delete()
                    .also { logger.info("Deleting progress for episode \(id), isComplete: \(isComplete)") }
                    .withHeaders(.bearer(token))
                    .response()
                    .withStatusCoreError(expecting: 202, feature: .audio)
            }
        }
    }
    
}

//public func updateProgress(
//    episodeID: UUID,
//    baseURL: String,
//    token: String,
//    isCompleted: Bool,
//    watchTime: Int
//) async throws(CoreError) {
//    try await CoreError.catchNetwork(performing: "Syncing episode progress", logger: logger, feature: .audio) {
//        try await Cobweb.URL.using(baseURL: baseURL)
//            .path("/api/episodes/\(episodeID)/progress")
//            .put()
//            .also { logger.info("Syncing progress for episode \(episodeID), watchTime: \(watchTime)") }
//            .withBody(ProgressUpdateRequest(isCompleted: isCompleted, watchTime: watchTime))
//            .withHeaders(.contentType(value: "application/json"), .bearer(token))
//            .response()
//            .withStatusCoreError(expecting: 202, feature: .audio)
//    }
//}
