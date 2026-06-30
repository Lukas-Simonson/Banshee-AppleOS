import Core
import Foundation

public protocol RemotePodcastDataSourceContract: Sendable {
    func podcasts(baseURL: String, token: String) async throws(CoreError) -> [Podcast]
    func registerFeed(from rssURL: URL, downloadMode: DownloadMode, baseURL: String, token: String) async throws(CoreError) -> Podcast
}
