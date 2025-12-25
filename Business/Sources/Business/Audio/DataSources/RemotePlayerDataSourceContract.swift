import Core
import Foundation

public protocol RemotePlayerDataSourceContract: Sendable {
    func episode(with id: UUID, baseURL: String, token: String) async throws -> Episode
}
