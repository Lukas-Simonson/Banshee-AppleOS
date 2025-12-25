import Core
import Business
import Foundation

public class UserDefaultsLocalQueueDataSource: LocalQueueDataSourceContract, @unchecked Sendable {
    
    private let defaults: UserDefaults
    
    private var queue: [UUID]? {
        get { (defaults.array(forKey: Keys.queue) as? [String])?.compactMap { UUID(uuidString: $0) } }
        set { defaults.set(newValue?.map { $0.uuidString }, forKey: Keys.queue) }
    }
    
    private var podcastImage: URL? {
        get { defaults.url(forKey: Keys.podcastImage) }
        set { defaults.set(newValue, forKey: Keys.podcastImage) }
    }
    
    private var position: Int? {
        get { defaults.integer(forKey: Keys.postition) }
        set { defaults.set(newValue, forKey: Keys.postition) }
    }
    
    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }
    
    public func get() -> AudioQueue? {
        guard let queue = self.queue,
              let position = self.position
        else { return nil }
        
        return AudioQueue(
            queue: queue,
            podcastImageURL: podcastImage,
            position: position
        )
    }
    
    public func save(_ queue: AudioQueue) {
        self.queue = queue.queue
        self.podcastImage = queue.podcastImageURL
        self.position = queue.position
    }
    
    public func clear() {
        self.queue = nil
        self.podcastImage = nil
        self.position = nil
    }
    
    enum Keys {
        static let queue = "com.bansheeaudio.audio.queue"
        static let podcastImage = "com.bansheeaudio.queue.podcastImageURL"
        static let postition = "com.bansheeaudio.queue.position"
    }
}
