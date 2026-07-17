import Core
import Foundation
import Logging
import Observation

@MainActor @Observable
final class BulkEpisodeConfigVM {
    // MARK: - Dependencies
    private let logger: Logger
    private let navigator: EpisodeNavigationContract
    private let repository: EpisodeConfigRepositoryContract
    
    // MARK: - State
    private(set) var isLoading = false
    private(set) var episodeIDs: Set<UUID>
    
    // MARK: - Initialization
    init(_ scaffold: EpisodeScaffoldContract, episodeIDs: Set<UUID>) {
        self.logger = scaffold.logger()
        self.navigator = scaffold.navigator()
        self.repository = scaffold.episodeConfigRepository()
        
        self.episodeIDs = episodeIDs
    }
    
    // MARK: - Actions
    public func save(season: ConfigValue<String>, imageURL: ConfigValue<URL>) {
        isLoading = true
        
        Task {
            defer { isLoading = false }
            
            do {
                try await repository.update(
                    BulkEpisodeConfig(ids: episodeIDs, season: season, imageURL: imageURL),
                    for: episodeIDs
                )
                navigateBack()
            } catch let error as CoreError {
                navigator.showError(error)
                logger.error("Error while saving bulk config", for: error)
            }
        }
    }
    
    public func navigateBack() { navigator.navigateBack() }
}
