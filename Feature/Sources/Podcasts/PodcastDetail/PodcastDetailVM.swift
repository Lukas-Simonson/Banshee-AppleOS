import Core
import Logging
import Observation

@MainActor @Observable
final class PodcastDetailVM {
    // MARK: - Dependencies
    private let logger: Logger
    private let navigator: PodcastNavigationContract
    private let repository: PodcastRepositoryContract
    
    // MARK: - State
    private(set) var podcast: Podcast
    private(set) var isLoading = false
    
    // MARK: - Initialization
    public init(_ scaffold: PodcastScaffoldContract, podcast: Podcast) {
        self.logger = scaffold.logger()
        self.navigator = scaffold.navigator()
        self.repository = scaffold.repository()
        
        self.podcast = podcast
        
        Task { await refresh() }
    }
    
    // MARK: - Actions
    public func refresh() async {
        do {
            self.podcast = try await repository.details(for: podcast)
        } catch let error as PodcastRepositoryError {
            navigator.showError(error)
        }
    }
}
