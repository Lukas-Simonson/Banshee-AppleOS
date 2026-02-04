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
    
    public func getPodcasts(baseURL: String, token: String) async throws(CoreError) -> [Podcast] {
        do {
            let response = try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/podcasts")
                .get()
                .also { logger.info("Sending Request to GET /api/podcasts") }
                .withHeaders(.bearer(token))
                .response()

            switch try response.statusCode {
                case 200: break
                case 401: throw CoreError.unauthorized(layer: .data, feature: .podcasts)
                case 404: throw CoreError.resourceNotFound(layer: .data, feature: .podcasts)
                case 500...599: throw CoreError.serverError(layer: .data, feature: .podcasts)
                default: throw CoreError.unexpectedResponse(
                    layer: .data,
                    feature: .podcasts,
                    code: try response.statusCode
                )
            }

            return try response.body(as: [PodcastDTO].self).map { $0.toCore() }
        } catch let error as CoreError {
            throw error
        } catch let error as Cobweb.URL.URLError {
            logger.error("Failed to create url for request", for: error)
            throw CoreError.urlError(layer: .data, feature: .podcasts)
        } catch let error as Cobweb.HTTP.Request.ResponseError {
            logger.error("Failed to get podcasts with a response error", for: error)
            throw CoreError.invalidResponseFormat(layer: .data, feature: .podcasts)
        } catch {
            logger.error("Unexpected error getting podcasts", for: error)
            throw CoreError.unexpected(layer: .data, feature: .podcasts)
        }
    }
    
    public func getPodcast(with id: UUID, baseURL: String, token: String) async throws(CoreError) -> Podcast {
        do {
            let response = try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/podcasts/\(id)")
                .query(.item(key: "includeEpisodeProgress", value: true))
                .get()
                .also { logger.info("Sending Request to GET /api/podcasts/\(id)") }
                .withHeaders(.bearer(token))
                .response()
            
            switch try response.statusCode {
                case 200: break
                case 401: throw CoreError.unauthorized(layer: .data, feature: .podcasts)
                case 404: throw CoreError.resourceNotFound(layer: .data, feature: .podcasts)
                case 500...599: throw CoreError.serverError(layer: .data, feature: .podcasts)
                default: throw CoreError.unexpectedResponse(
                    layer: .data,
                    feature: .podcasts,
                    code: try response.statusCode
                )
            }

            return try response.body(as: PodcastDTO.self, JSONDecoder().withISO8601()).toCore()            
        } catch let error as CoreError {
            throw error
        } catch let error as Cobweb.URL.URLError {
            logger.error("Failed to create url for request", for: error)
            throw CoreError.urlError(layer: .data, feature: .podcasts)
        } catch let error as Cobweb.HTTP.Request.ResponseError {
            logger.error("Failed to get the podcast with a response error", for: error)
            throw CoreError.invalidResponseFormat(layer: .data, feature: .podcasts)
        } catch {
            logger.error("Unexpected error getting podcasts", for: error)
            throw CoreError.unexpected(layer: .data, feature: .podcasts)
        }
    }
    
    public func getConfig(podcastID: UUID, baseURL: String, token: String) async throws(CoreError) -> (Podcast, PodcastConfig) {
        do {
            let response = try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/podcasts/\(podcastID)")
                .query(.item(key: "includeEpisodes", value: false), .item(key: "config", value: "include"))
                .get()
                .also { logger.info("Sending Request to GET /api/podcasts/\(podcastID)") }
                .withHeaders(.bearer(token))
                .response()
            
            switch try response.statusCode {
                case 200: break
                case 401: throw CoreError.unauthorized(layer: .data, feature: .podcasts)
                case 404: throw CoreError.resourceNotFound(layer: .data, feature: .podcasts)
                case 500...599: throw CoreError.serverError(layer: .data, feature: .podcasts)
                default: throw CoreError.unexpectedResponse(
                    layer: .data,
                    feature: .podcasts,
                    code: try response.statusCode
                )
            }

            return try response.body(as: PodcastDTO.self, JSONDecoder().withISO8601()).toCoreWithConfig()
        } catch let error as CoreError {
            throw error
        } catch let error as Cobweb.URL.URLError {
            logger.error("Failed to create url for request", for: error)
            throw CoreError.urlError(layer: .data, feature: .podcasts)
        } catch let error as Cobweb.HTTP.Request.ResponseError {
            logger.error("Failed to get the podcast with a response error", for: error)
            throw CoreError.invalidResponseFormat(layer: .data, feature: .podcasts)
        } catch {
            logger.error("Unexpected error getting podcasts", for: error)
            throw CoreError.unexpected(layer: .data, feature: .podcasts)
        }
    }
    
    public func postConfig(_ config: PodcastConfig, baseURL: String, token: String) async throws(CoreError) {
        do {
            let response = try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/podcasts/\(config.podcastID)/config")
                .post()
                .withBody(config.toDTO())
                .also { logger.info("Sending Request to POST /api/podcasts/\(config.podcastID)/config") }
                .withHeaders(.bearer(token))
                .response()
            
            switch try response.statusCode {
                case 200: break
                case 401: throw CoreError.unauthorized(layer: .data, feature: .podcasts)
                case 404: throw CoreError.resourceNotFound(layer: .data, feature: .podcasts)
                case 500...599: throw CoreError.serverError(layer: .data, feature: .podcasts)
                default: throw CoreError.unexpectedResponse(
                    layer: .data,
                    feature: .podcasts,
                    code: try response.statusCode
                )
            }
        } catch let error as CoreError {
            throw error
        } catch let error as Cobweb.URL.URLError {
            logger.error("Failed to create url for request", for: error)
            throw CoreError.urlError(layer: .data, feature: .podcasts)
        } catch let error as Cobweb.HTTP.Request.ResponseError {
            logger.error("Failed to get the podcast with a response error", for: error)
            throw CoreError.invalidResponseFormat(layer: .data, feature: .podcasts)
        } catch {
            logger.error("Unexpected error getting podcasts", for: error)
            throw CoreError.unexpected(layer: .data, feature: .podcasts)
        }
    }
}
