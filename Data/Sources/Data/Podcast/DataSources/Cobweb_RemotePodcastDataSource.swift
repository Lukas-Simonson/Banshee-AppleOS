import Business
import Cobweb
import Core
import Foundation
import Logging

public struct Cobweb_RemotePodcastDataSource: _RemotePodcastDataSourceContract {
    private var logger: Logger
    
    public init(logger: Logger) {
        self.logger = logger
    }
    
    public func podcasts(baseURL: String, token: String) async throws(CoreError) -> [Podcast] {
        try await CoreError.catchNetwork(performing: "Getting podcasts", logger: logger, feature: .podcasts) {
            try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/podcasts")
                .get()
                .also { logger.info("Sending request to GET /api/podcasts") }
                .withHeaders(.bearer(token))
                .response()
                .withStatusCoreError(expecting: 200, feature: .podcasts)
                .body(as: [PodcastDTO].self)
                .map { $0.toCore() }
        }
    }
}
