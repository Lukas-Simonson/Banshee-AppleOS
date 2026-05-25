import Core
import Foundation
import Logging
import Observation

@MainActor @Observable
final class EpisodeConfigVM {
    // MARK: - Dependencies
    private let logger: Logger
    private let navigator: EpisodeNavigationContract
    private let repository: EpisodeConfigRepositoryContract
    
    // MARK: - State
    private(set) var isLoading = true
    private(set) var episode: Episode
    var config = EpisodeConfig(episodeID: UUID())
    
    // MARK: - Initialization
    public init(_ scaffold: EpisodeScaffoldContract, episode: Episode) {
        self.logger = scaffold.logger()
        self.navigator = scaffold.navigator()
        self.repository = scaffold.episodeConfigRepository()
        
        self.episode = episode
        load(episode)
    }
    
    // MARK: - Actions
    public func load(_ episode: Episode) {
        isLoading = true
        
        Task {
            defer { isLoading = false }
            
            do {
                let (episode, config) = try await repository.config(for: episode)
                
                self.episode = episode
                self.config = config
            } catch let error as CoreError {
                navigator.navigateBack()
                navigator.showError(error)
                logger.error("Error while loading episode config", for: error)
            }
        }
    }
    
    public func save() {
        isLoading = true
        
        Task {
            defer { isLoading = false }
            
            do {
                try await repository.update(config, for: episode)
                navigator.navigateBack()
            } catch let error as CoreError {
                navigator.showError(error)
                logger.error("Error while saving episode config", for: error)
            }
        }
    }
    
    public func navigateBack() { navigator.navigateBack() }
}
