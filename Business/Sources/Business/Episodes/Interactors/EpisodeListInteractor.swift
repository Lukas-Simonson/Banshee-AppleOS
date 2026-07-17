import Core
import Foundation
import Logging
import Overflow

@Observable
public final class EpisodeListInteractor: EpisodeListInteractorContract, @unchecked Sendable {
    
    // MARK: - Dependencies
    private let repository: EpisodeRepositoryContract
    private let storage: KeyValueStoreContract
    private let logger: Logger
    
    // MARK: - Shared State
    public private(set) var order: Episode.Order = .title(asc: true)
    public private(set) var scroll: UUID?
    public private(set) var selectedEpisodeIDs: Set<UUID> = []
    
    public var episodeStream: any AsyncSequence<[Episode], Never> {
        flow
    }
    
    // MARK: - Private State
    private var flow = MutableStateFlow<[Episode]>(initial: [])
    private var podcast: Podcast?
    private var episodeObservation: Task<Void, Never>?
    private var scrollDebounce: Debounce<UUID?>!
    
    public init(repository: EpisodeRepositoryContract, storage: KeyValueStoreContract, logger: Logger) {
        self.repository = repository
        self.storage = storage
        self.logger = logger
        scrollDebounce = Debounce(saveScroll, for: .seconds(1))
    }
    
    // MARK: - Actions
    
    public func updateSelected(_ newIDs: Set<UUID>) {
        selectedEpisodeIDs = newIDs
    }
    
    public func updateOrder(_ newOrder: Episode.Order) {
        guard let podcast else { return }
        
        self.order = newOrder
        self.scroll = nil
        storage.store(nil as UUID?, for: "\(podcast.id)/scroll")
        storage.store(newOrder, for: "\(podcast.id)/sort")
        observe()
    }
    
    public func updateScroll(_ newScroll: UUID?) {
        self.scroll = newScroll
        scrollDebounce(newScroll)
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
                    
                    // Keep scroll
                    if let newScroll = storage.value(for: "\(podcast.id)/scroll", ofType: UUID.self) {
                        self.scroll = newScroll
                    }
                }
            } catch {
                // TODO: Handle these errors
            }
        }
    }
    
    @Sendable
    private func saveScroll(with id: UUID?) {
        if let podcastID = podcast?.id {
            logger.info("Updating persisted scroll for podcast with id: \(podcast?.id) to episode with id: \(id)")
            storage.store(id, for: "\(podcastID)/scroll")
        }
    }
    
    deinit {
        episodeObservation?.cancel()
        scrollDebounce.cancel()
    }
}
