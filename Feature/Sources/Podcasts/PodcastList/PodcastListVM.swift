import Core
import Logging
import Observation

@MainActor @Observable
final class PodcastListVM {
    // MARK: - Dependencies
    private let logger: Logger
    private let navigator: PodcastNavigationContract
    private let repository: PodcastRepositoryContract
    
    // MARK: - State
    private(set) var podcasts = [Podcast]()
    private(set) var isLoading = false
    
    // MARK: - Initialization
    public init(_ scaffold: PodcastScaffoldContract) {
        self.logger = scaffold.logger()
        self.navigator = scaffold.navigator()
        self.repository = scaffold.repository()
        
        observePodcasts()
    }
    
    // MARK: - Actions
    public func selectPodcast(_ podcast: Podcast) {
        navigator.navigateToDetail(for: podcast)
    }
    
    public func refresh() async {
        do {
            try await repository.refresh()
        } catch let error as PodcastRepositoryError {
            navigator.showError(error)
        }
    }
    
    // MARK: - Private Methods
    private func observePodcasts() {
        Task { [weak self] in
            self?.loadPodcasts()
            guard let stream = self?.repository.podcastsStream else { return }
            
            for await podcasts in stream {
                guard let self else { break }
                self.podcasts = podcasts
            }
        }
    }
    
    private func loadPodcasts() {
        Task {
            guard await repository.podcasts.isEmpty
            else { return }
            logger.info("Fetching")
            isLoading = true
            
            do {
                try await self.repository.refresh()
            } catch let error as PodcastRepositoryError {
                navigator.showError(error)
            }
            
            isLoading = false
        }
    }
}
