import Core
import Foundation
import Logging
import Observation

@MainActor @Observable
final class PodcastConfigVM {
    // MARK: - Dependencies
    private let logger: Logger
    private let navigator: PodcastNavigationContract
    private let repository: PodcastConfigRepositoryContract
    
    // MARK: - State
    private(set) var isLoading = true
    private(set) var podcast: Podcast
    var config = PodcastConfig(title: nil, imageURL: nil, description: nil, podcastID: UUID())
    
    // MARK: - Initialization
    public init(_ scaffold: PodcastScaffoldContract, podcast: Podcast) {
        self.logger = scaffold.logger()
        self.navigator = scaffold.navigator()
        self.repository = scaffold.podcastConfigRepository()
                
        self.podcast = podcast
        
        load(podcast)
    }
    
    // MARK: - Actions
    public func load(_ podcast: Podcast) {
        isLoading = true
        
        Task {
            defer { isLoading = false }
            
            do {
                let (podcast, config) = try await repository.config(for: podcast)
                
                self.podcast = podcast
                self.config = config
            } catch let error as CoreError {
                navigator.navigateBack()
                navigator.showError(error)
                logger.error("Error while loading podcast config", for: error)
            }
        }
    }
    
    public func save() {
        isLoading = true
        
        Task {
            defer { isLoading = false }
            
            do {
                try await repository.update(config, for: podcast)
                navigator.navigateBack()
            } catch let error as CoreError {
                navigator.showError(error)
                logger.error("Error while saving podcast config", for: error)
            }
        }
    }
    
    public func navigateBack() { navigator.navigateBack() }
}
