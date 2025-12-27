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
        
        Task { await refresh(force: false) }
    }
    
    // MARK: - Actions
    
    public func play(_ episode: Episode) {
        guard let episodes = podcast.episodes else { return }
        isStartingPlayback = true
        
        Task {
            defer { isStartingPlayback = false }
            
            do {
                guard let index = episodes.firstIndex(where: { $0.id == episode.id })
                else { return }
                
                do {
                    try await player.enqueue(
                        AudioQueue(
                            queue: episodes.map { $0.id },
                            podcastName: podcast.title,
                            podcastImageURL: podcast.imageURL,
                            position: index
                        ),
                        startPlaying: true
                    )
                } catch let error as EpisodePlayerError {
                    logger.error("Failed to play episode", for: error)
                    navigator.showError(error)
                }
            }
        }
    }
    
    public func refresh(force: Bool = false) async {
        for await result in repository.details(for: podcast, refresh: force) {
            switch result {
                case .success(let podcast): self.podcast = podcast
                case .failure(let error): self.navigator.showError(error)
            }
        }
    }
    
    public func navigateBack() { navigator.navigateBack() }
}
