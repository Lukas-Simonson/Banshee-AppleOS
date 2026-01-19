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
        do {
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
        } catch let error as CoreError {
            throw error
        } catch let error as Cobweb.URL.URLError {
            logger.error("Unable to create URL", for: error)
            throw CoreError.urlError(layer: .data, feature: .auth)
        } catch let error as Cobweb.HTTP.Request.ResponseError {
            logger.error("Server Verification failed with response error", for: error)
            throw CoreError.invalidResponseFormat(layer: .data, feature: .auth)
        } catch {
            logger.error("Unknown error found during server verification", for: error)
            throw CoreError.unexpected(layer: .data, feature: .auth)
        }
    }

    public func updateProgress(
        episodeId: UUID,
        baseURL: String,
        token: String,
        isCompleted: Bool,
        watchTime: Int
    ) async throws(CoreError) {
        do {
            let response = try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/episodes/\(episodeId)/progress")
                .post()
                .also { logger.info("Syncing progress for episode \(episodeId): \(watchTime)s") }
                .withBody(ProgressUpdateRequest(isCompleted: isCompleted, watchTime: watchTime))
                .withHeaders(.contentType(value: "application/json"))
                .withHeaders(.bearer(token))
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
        } catch let error as CoreError {
            throw error
        } catch let error as Cobweb.URL.URLError {
            logger.error("Unable to create URL", for: error)
            throw CoreError.urlError(layer: .data, feature: .auth)
        } catch let error as Cobweb.HTTP.Request.ResponseError {
            logger.error("Server Verification failed with response error", for: error)
            throw CoreError.invalidResponseFormat(layer: .data, feature: .auth)
        } catch {
            logger.error("Unknown error found during server verification", for: error)
            throw CoreError.unexpected(layer: .data, feature: .auth)
        }
    }
}

extension CobwebRemotePlayerDataSource {
    struct ProgressUpdateRequest: Codable {
        let isCompleted: Bool
        let watchTime: Int
    }
}
