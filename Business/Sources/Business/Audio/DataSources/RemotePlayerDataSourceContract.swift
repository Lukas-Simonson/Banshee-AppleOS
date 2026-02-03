import Core
import Foundation

public protocol RemotePlayerDataSourceContract: Sendable {
    func episode(with id: UUID, baseURL: String, token: String) async throws(CoreError) -> Episode

    func updateProgress(
        episodeId: UUID,
        baseURL: String,
        token: String,
        isCompleted: Bool,
        watchTime: Int
    ) async throws(CoreError)
}
