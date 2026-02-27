import Core
import Foundation
import Observation
import SwiftUI

@MainActor @Observable
public final class ImageCache {
    
    public static let shared = ImageCache()
    
    private let cachedImageSize = CGSize(width: 300, height: 300)
    private var cache = [URL: UIImage]()
    
    @ObservationIgnored
    private var tasks = [URL: Task<UIImage, any Error>]()
    
    private init() { }
    
    public func load(_ url: URL) -> UIImage? {
        // Pull image from cache if possible.
        if let image = cache[url] {
            return image
        }
        
        // Check if image is already being fetched.
        if tasks[url] == nil {
            // Spawn a task to cache the image.
            tasks[url] = Task { try await cacheImage(at: url) }
        }
        
        return nil
    }
    
    @concurrent
    nonisolated public func getImage(at url: URL) async throws -> UIImage {
        if let image = await cache[url] {
            return image
        } else if let task = await tasks[url] {
            return try await task.value
        } else {
            return try await MainActor.run {
                tasks[url] = Task { try await cacheImage(at: url) }
                return tasks[url]!
            }.value
        }
    }
    
    @concurrent @discardableResult
    private func cacheImage(at url: URL) async throws -> UIImage {
        let (imageData, _) = try await URLSession.shared.data(from: url)
        
        guard let image = UIImage(data: imageData),
              let thumbnail = image.preparingThumbnail(of: cachedImageSize)
        else { throw CoreError.dataCorrupted(layer: .feature, feature: .audio) }
        
        await MainActor.run {
            cache[url] = thumbnail
            tasks.removeValue(forKey: url)
        }
        
        return thumbnail
    }
}
