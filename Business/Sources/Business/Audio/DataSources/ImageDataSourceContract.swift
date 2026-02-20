import UIKit.UIImage

public protocol ImageDataSourceContract: Sendable {
    @concurrent
    nonisolated func getImage(at url: URL) async throws -> UIImage
}
