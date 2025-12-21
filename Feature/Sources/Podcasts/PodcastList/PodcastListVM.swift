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
            guard let stream = self?.repository.podcastsStream else { return }
            
            for await podcasts in stream {
                guard let self else { break }
                self.podcasts = podcasts
            }
        }
    }
}
