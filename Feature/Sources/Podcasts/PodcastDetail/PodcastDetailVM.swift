import Core
import Logging
import Observation

@MainActor @Observable
final class PodcastDetailVM {
    // MARK: - Dependencies
    private let logger: Logger
    private let navigator: PodcastNavigationContract
    private let podcastRepository: PodcastRepositoryContract
    private let episodeRepository: EpisodeRepositoryContract
    private let player: EpisodePlayerContract
    
    // MARK: - State
    private(set) var podcast: Podcast
    private(set) var episodes = [Episode]()
    private(set) var isLoading = false
    private(set) var isStartingPlayback = false
    
    // MARK: - Initialization
    public init(_ scaffold: PodcastScaffoldContract, podcast: Podcast) {
        self.logger = scaffold.logger()
        self.navigator = scaffold.navigator()
        self.podcastRepository = scaffold.podcastRepository()
        self.episodeRepository = scaffold.episodeRepository()
        self.player = scaffold.player()
        
        self.podcast = podcast
        
        observePodcastAndEpisodes()
    }
    
    // MARK: - Actions
    
    public func play(_ episode: Episode) {
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
                } catch let error as CoreError {
                    logger.error("Failed to play episode", for: error)
                    navigator.showError(error)
                }
            }
        }
    }
    
    public func refresh(force: Bool = false) async {
        isLoading = !force // Only set isLoading on initial load.
        defer { isLoading = false }
        
        do {
            async let updatePodcast = podcastRepository.refreshPodcast(with: podcast.id, force: force)
            async let updateEpisodes = episodeRepository.refreshEpisodes(of: podcast, force: force)
            
            try await (updatePodcast, updateEpisodes)
        } catch let error as CoreError {
            navigator.showError(error)
        } catch {
            logger.warning("Caught a non-core error", for: error)
        }
    }
    
    public func navigateToEditConfig() { navigator.navigateToEditConfig(for: podcast) }
    
    public func navigateBack() { navigator.navigateBack() }
    
    // MARK: - Private Methods
    
    public func observePodcastAndEpisodes() {
        Task { await self.refresh() }
        
        Task { [weak self] in
            guard let podcast = self?.podcast,
                  let stream = self?.podcastRepository.observePodcast(with: podcast.id)
            else { return }
            
            do {
                for await update in stream {
                    guard let self else { break }
                    self.podcast = try update.get()
                }
            } catch let error as CoreError {
                self?.navigator.showError(error)
            }
        }
        
        Task { [weak self] in
            guard let podcast = self?.podcast,
                  let stream = self?.episodeRepository.observeEpisodes(of: podcast)
            else { return }
            
            do {
                for await update in stream {
                    guard let self else { break }
                    self.episodes = try update.get()
                }
            } catch let error as CoreError {
                self?.navigator.showError(error)
            }
        }
    }
}
