import Cobweb
import Core
import Logging

extension Cobweb.HTTP.Response {
    
    func withStatusCoreError(expecting: Int, feature: CoreError.Feature) throws(CoreError) -> Self {
        do {
            switch try statusCode {
                case expecting: break
                case 401: throw CoreError.unauthorized(layer: .data, feature: feature)
                case 404: throw CoreError.resourceNotFound(layer: .data, feature: feature)
                case 500...599: throw CoreError.serverError(layer: .data, feature: feature)
                default: throw CoreError.unexpectedResponse(layer: .data, feature: feature, code: try statusCode)
            }
            
            return self
        } catch let error as CoreError {
            throw error
        } catch {
            throw CoreError.invalidResponseFormat(layer: .data, feature: feature)
        }
    }
}

extension CoreError {
    static func catchNetwork(
        performing: String,
        logger: Logger,
        feature: Feature,
        _ action: () async throws -> Void
    ) async throws(CoreError) {
        try await catchNetwork(performing: performing, logger: logger, feature: feature, action: {
            try await action()
        })
    }
    
    static func catchNetwork<T>(
        performing: String,
        logger: Logger,
        feature: Feature,
        action: () async throws -> T
    ) async throws(CoreError) -> T {
        do {
            return try await action()
        } catch let error as CoreError {
            throw error
        } catch let error as Cobweb.URL.URLError {
            logger.error("Failed to create url for request", for: error)
            throw CoreError.urlError(layer: .data, feature: feature)
        } catch let error as Cobweb.HTTP.Request.ResponseError {
            logger.error("Got a response error while \(performing)", for: error)
            throw CoreError.invalidResponseFormat(layer: .data, feature: feature)
        } catch {
            logger.error("Unexpected error while \(performing)", for: error)
            throw CoreError.unexpected(layer: .data, feature: feature)
        }
    }
}
