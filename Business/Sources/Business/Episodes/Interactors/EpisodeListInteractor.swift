import Core
import Foundation
import Overflow

public final class EpisodeListInteractor: EpisodeListInteractorContract, @unchecked Sendable {
    
    // MARK: - Dependencies
    private let repository: EpisodeRepositoryContract
    private let storage: KeyValueStoreContract
    
    // MARK: - Shared State
    public var order: Episode.Order = .title(asc: true)
    
    public var episodeStream: AsyncSequence<[Episode], Never> {
        flow
    }
    
    // MARK: - Private State
    private var flow = MutableStateFlow<[Episode]>(initial: [])
    private var podcast: Podcast?
    private var episodeObservation: Task<Void, Never>?
    
    public init(repository: EpisodeRepositoryContract, storage: KeyValueStoreContract) {
        self.repository = repository
        self.storage = storage
    }
    
    // MARK: - Actions
    
    public func updateOrder(_ newOrder: Episode.Order) {
        guard let podcast else { return }
        
        self.order = newOrder
        storage.store(newOrder, for: "\(podcast.id)/sort")
        observe()
    }
    
    public func stream(podcast: Podcast) {
        self.podcast = podcast
        
        if let newOrder = storage.value(for: "\(podcast.id)/sort", ofType: Episode.Order.self) {
            self.order = newOrder
        }
        
        observe()
    }
    
    public func refresh(force: Bool) async throws(CoreError) {
        guard let podcast else { return }
        try await repository.refreshEpisodes(of: podcast, force: force)
    }
    
    // MARK: - Helper Methods
    private func observe() {
        guard let podcast else { return }
        
        episodeObservation?.cancel()        
        episodeObservation = Task { [weak self] in
            do {
                guard let order = self?.order,
                      let podcast = self?.podcast,
                      let stream = self?.repository.observeEpisodes(of: podcast, order: order)
                else { return }
                
                for await update in stream {
                    guard let self, !Task.isCancelled else { break }
                    try await self.flow.emit(update.get())
                }
            } catch {
                // TODO: Handle these errors
            }
        }
    }
    
    deinit {
        episodeObservation?.cancel()
    }
}
