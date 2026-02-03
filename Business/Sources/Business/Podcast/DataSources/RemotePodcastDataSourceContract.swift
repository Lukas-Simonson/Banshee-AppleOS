import Core
import Foundation

public protocol RemotePodcastDataSourceContract: Sendable {
    func getPodcasts(baseURL: String, token: String) async throws(CoreError) -> [Podcast]

    func getPodcast(with id: UUID, baseURL: String, token: String) async throws(CoreError) -> Podcast
}
