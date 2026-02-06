import Core
import Foundation
import Logging
import Overflow

public struct EpisodeRepository: EpisodeRepositoryContract {
    
    // MARK: - Dependencies
    private let logger: Logger
    private let serverProvider: ServerProviderContract
//    private let local: _LocalPodcastDataSourceContract
//    private let remote: _RemotePodcastDataSourceContract
    
    public func observeEpisodes(of podcast: Podcast) -> AsyncResultSequence<[Episode], CoreError> {
        fatalError()
    }
}

protocol LocalEpisodeDataSource: Sendable {
    
}

protocol RemoteEpisodeDataSource: Sendable {
    
}
