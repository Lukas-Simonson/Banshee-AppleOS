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
    
    public func registerFeed(from rssURL: URL, downloadMode: DownloadMode, baseURL: String, token: String) async throws(CoreError) -> Podcast {
        try await CoreError.catchNetwork(performing: "Registering RSS feed", logger: logger, feature: .podcasts) {
            try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/podcasts/feeds")
                .post()
                .withHeaders(.bearer(token), .contentType(value: "application/json"))
                .withBody([
                    "url": rssURL.absoluteString,
                    "autoDownload": downloadModeString(for: downloadMode)
                ])
                .response()
                .withStatusCoreError(expecting: 201, feature: .podcasts)
                .body(as: PodcastDTO.self)
                .toCore()
        }
    }
    
    private func downloadModeString(for mode: DownloadMode) -> String {
        switch mode {
            case .new: "new"
            case .newAndExisting: "new_and_existing"
            case .none: "none"
        }
    }
}
