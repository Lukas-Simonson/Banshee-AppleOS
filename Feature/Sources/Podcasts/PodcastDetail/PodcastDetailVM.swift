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
    private let episodeListInteractor: EpisodeListInteractorContract
    private let player: EpisodePlayerContract
    
    // MARK: - State
    private(set) var podcast: Podcast
    private(set) var episodes = [Episode]()
    private(set) var isLoading = false
    private(set) var isStartingPlayback = false
    
    var sortOrder: Episode.Order {
        get { episodeListInteractor.order }
        set { episodeListInteractor.updateOrder(newValue) }
    }
    
    private var episodeObservation: Task<Void, any Error>?
    
    // MARK: - Initialization
    public init(_ scaffold: PodcastScaffoldContract, podcast: Podcast) {
        self.logger = scaffold.logger()
        self.navigator = scaffold.navigator()
        self.podcastRepository = scaffold.podcastRepository()
        self.episodeRepository = scaffold.episodeRepository()
        self.episodeListInteractor = scaffold.episodeListInteractor()
        self.player = scaffold.player()
        
        self.podcast = podcast
        
        observePodcastAndEpisodes()
        episodeListInteractor.stream(podcast: podcast)
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
            // async let updatePodcast = podcastRepository.refreshPodcast(with: podcast.id, force: force)
            async let updateEpisodes = episodeListInteractor.refresh(force: force)
            
            try await (updateEpisodes)
        } catch let error as CoreError {
            navigator.showError(error)
        } catch {
            logger.warning("Caught a non-core error", for: error)
        }
    }
    
    public func toggleCompletion(for episode: Episode) {
        Task {
            do {
                try await episodeRepository.toggleEpisodeComplete(episode)
            } catch let error as CoreError {
                navigator.showError(error)
                logger.error("Failed toggling completion", for: error)
            }
        }
    }
    
    public func navigateToEditConfig() { navigator.navigateToEditConfig(for: podcast) }
    
    public func navigateBack() { navigator.navigateBack() }
    
    // MARK: - Private Methods
    
    private func observePodcastAndEpisodes() {
        Task { await self.refresh() }
        
        observeEpisodes()
        
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
    }
    
    private func observeEpisodes() {
        episodeObservation?.cancel()
        episodeObservation = Task { [weak self] in
            guard let stream = self?.episodeListInteractor.episodeStream else { return }
            for await update in stream {
                guard let self, !Task.isCancelled else { break }
                self.episodes = update
            }
        }
    }
}
