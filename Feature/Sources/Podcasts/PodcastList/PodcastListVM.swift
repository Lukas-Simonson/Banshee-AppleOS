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
    init(_ scaffold: PodcastScaffoldContract) {
        self.logger = scaffold.logger()
        self.navigator = scaffold.navigator()
        self.repository = scaffold.podcastRepository()
    
        observePodcasts()
    }
    
    // MARK: - Actions
    public func selectPodcast(_ podcast: Podcast) {
        navigator.navigateToDetail(for: podcast)
    }
    
    public func refresh(force: Bool) async {
        do {
            try await repository.refreshPodcasts(force: force)
        } catch let error {
            navigator.showError(error)
        }
    }
    
    // MARK: - Private Methods
    private func observePodcasts() {
        Task { [weak self] in
            Task { await self?.refresh(force: false) }
            
            guard let stream = self?.repository.observePodcasts() else { return }
            
            do {
                for await podcasts in stream {
                    guard let self else { break }
                    self.podcasts = try podcasts.get()
                }
            } catch let error as CoreError {
                self?.navigator.showError(error)
            }
        }
    }
}
