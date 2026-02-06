import Core
import Foundation

public protocol RemotePodcastDataSourceContract: Sendable {
    func podcasts(baseURL: String, token: String) async throws(CoreError) -> [Podcast]
}
