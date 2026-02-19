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
    
    public func episode(with id: UUID, baseURL: String, token: String) async throws(CoreError) -> Episode {
        try await CoreError.catchNetwork(performing: "fetching episode", logger: logger, feature: .audio) {
            let response = try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/episodes/\(id)")
                .get()
                .also { logger.info("Making request to /api/episodes/\(id)") }
                .withHeaders(.bearer(token))
                .response()

            switch try response.statusCode {
                case 200: break
                case 401: throw CoreError.unauthorized(layer: .data, feature: .audio)
                case 404: throw CoreError.resourceNotFound(layer: .data, feature: .audio)
                case 500...599: throw CoreError.serverError(layer: .data, feature: .audio)
                default: throw CoreError.unexpectedResponse(
                    layer: .data,
                    feature: .audio,
                    code: try response.statusCode
                )
            }

            return try response.body(as: EpisodeDTO.self, JSONDecoder().withISO8601()).toCore()
        }
    }

    public func updateProgress(
        episodeID: UUID,
        baseURL: String,
        token: String,
        isCompleted: Bool,
        watchTime: Int
    ) async throws(CoreError) {
        try await CoreError.catchNetwork(performing: "Syncing episode progress", logger: logger, feature: .audio) {
            let response = try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/episodes/\(episodeID)/progress")
                .put()
                .also { logger.info("Syncing progress for episode \(episodeID), watchTime: \(watchTime)") }
                .withBody(ProgressUpdateRequest(isCompleted: isCompleted, watchTime: watchTime))
                .withHeaders(.contentType(value: "application/json"), .bearer(token))
                .response()
            
            switch try response.statusCode {
                case 202: break
                case 401: throw CoreError.unauthorized(layer: .data, feature: .audio)
                case 404: throw CoreError.resourceNotFound(layer: .data, feature: .audio)
                case 500...599: throw CoreError.serverError(layer: .data, feature: .audio)
                default: throw CoreError.unexpectedResponse(
                    layer: .data,
                    feature: .audio,
                    code: try response.statusCode
                )
            }
        }
    }
}

extension CobwebRemotePlayerDataSource {
    struct ProgressUpdateRequest: Codable {
        let isCompleted: Bool
        let watchTime: Int
    }
}
