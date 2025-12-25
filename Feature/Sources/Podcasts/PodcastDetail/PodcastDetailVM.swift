import Core
import Logging
import Observation

@MainActor @Observable
final class PodcastDetailVM {
    // MARK: - Dependencies
    private let logger: Logger
    private let navigator: PodcastNavigationContract
    private let repository: PodcastRepositoryContract
    private let player: EpisodePlayerContract
    
    // MARK: - State
    private(set) var podcast: Podcast
    private(set) var isLoading = false
    private(set) var isStartingPlayback = false
    
    // MARK: - Initialization
    public init(_ scaffold: PodcastScaffoldContract, podcast: Podcast) {
        self.logger = scaffold.logger()
        self.navigator = scaffold.navigator()
        self.repository = scaffold.repository()
        self.player = scaffold.player()
        
        self.podcast = podcast
        
        Task { await refresh() }
    }
    
    // MARK: - Actions
    
    public func play(at position: Int) {
        guard let episodes = podcast.episodes else { return }
        isStartingPlayback = true
        
        Task {
            defer { isStartingPlayback = false }
            
            do {
                try await player.enqueue(episodes[position...].map { $0.id })
            } catch {
                logger.error("Error", for: error)
            }
        }
    }
    
    public func refresh() async {
        do {
            self.podcast = try await repository.details(for: podcast)
        } catch let error as PodcastRepositoryError {
            navigator.showError(error)
        }
    }
}
