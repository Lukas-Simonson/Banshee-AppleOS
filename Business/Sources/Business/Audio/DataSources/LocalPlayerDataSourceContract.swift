import Core
import Foundation

public protocol LocalPlayerDataSourceContract: Sendable {
    func updateProgress(
        episodeID: UUID,
        isCompleted: Bool,
        watchTime: Int
    ) async throws(CoreError)
}
