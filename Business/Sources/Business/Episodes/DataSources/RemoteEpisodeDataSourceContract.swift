import Core
import Foundation

public protocol RemoteEpisodeDataSourceContract: Sendable {
    func episodes(with podcastID: UUID, baseURL: String, token: String) async throws(CoreError) -> [Episode]
    
    func updateEpisodeCompletion(with id: UUID, isComplete: Bool, baseURL: String, token: String) async throws(CoreError)
}
