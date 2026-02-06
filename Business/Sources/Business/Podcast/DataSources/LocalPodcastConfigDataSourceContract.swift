import Core
import Foundation

public protocol LocalPodcastConfigDataSourceContract: Sendable {
    func updatePodcast(with config: PodcastConfig) async throws(CoreError)
}
