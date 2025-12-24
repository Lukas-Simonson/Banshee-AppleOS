import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class ImageCache {
    
    static let shared = ImageCache()
    
    private let cachedImageSize = CGSize(width: 200, height: 200)
    private var cache = [URL: UIImage]()
    
    @ObservationIgnored
    private var tasks = [URL: Task<Void, Never>]()
    
    private init() { }
    
    func load(_ url: URL) -> UIImage? {
        // Pull image from cache if possible.
        if let image = cache[url] {
            return image
        }
        
        // Check if image is already being fetched.
        if tasks[url] == nil {
            // Spawn a task to cache the image.
            tasks[url] = Task { await cacheImage(at: url) }
        }
        return nil
    }
    
    @concurrent
    func cacheImage(at url: URL) async {
        do {
            let (imageData, _) = try await URLSession.shared.data(from: url)
            
            guard let image = UIImage(data: imageData) else { return }
            let thumbnail = image.preparingThumbnail(of: cachedImageSize)
            
            await MainActor.run {
                cache[url] = thumbnail
                tasks.removeValue(forKey: url)
            }
        } catch {
            // Skip handling errors for image caching
        }
    }
}
