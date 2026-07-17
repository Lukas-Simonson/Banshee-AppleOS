import Business
import Core
import Foundation
import GRDB
import Logging

public struct GRDBLocalEpisodeConfigDataSource: LocalEpisodeConfigDataSourceContract {
    
    private let dbManager: DatabaseManager
    private let logger: Logger
    
    public init(dbManager: DatabaseManager, logger: Logger) {
        self.dbManager = dbManager
        self.logger = logger
    }
    
    public func updateEpisode(with config: EpisodeConfig) async throws(CoreError) {
        try await CoreError.catchDatabase(performing: "Updating episode config", logger: logger, feature: .episodes) {
            try await dbManager.dbQueue.write { db in
                var assignments = [ColumnAssignment]()
                
                // TODO: Fix Overrides - #18
                
                if let title = config.title {
                    assignments.append(EpisodeRecord.Columns.title.set(to: title))
                }
                
                if let description = config.description {
                    assignments.append(EpisodeRecord.Columns.description.set(to: description))
                }
                
                if let imageURL = config.imageURL {
                    assignments.append(EpisodeRecord.Columns.imageURL.set(to: imageURL))
                }
                
                if let season = config.season {
                    assignments.append(EpisodeRecord.Columns.season.set(to: season))
                }
                
                if let episode = config.episode {
                    assignments.append(EpisodeRecord.Columns.episode.set(to: episode))
                }
                
                guard !assignments.isEmpty else { return }
                
                try EpisodeRecord
                    .filter(EpisodeRecord.Columns.id == config.episodeID)
                    .updateAll(db, assignments)
            }
        }
    }
    
    public func updateEpisodes(_ episodes: [Episode]) async throws(CoreError) {
        // Updating one by one, as using a bulk config won't work when nullifying fields as they would go back to their default,
        // which we don't store locally. See #18 as this implements the fix over the current updateEpisode implementation.
        try await CoreError.catchDatabase(performing: "Updating bulk episodes", logger: logger, feature: .episodes) {
            try await dbManager.dbQueue.write { db in
                for episode in episodes {
                    try EpisodeRecord
                        .filter(EpisodeRecord.Columns.id == episode.id)
                        .updateAll(db, [
                            EpisodeRecord.Columns.season.set(to: episode.season),
                            EpisodeRecord.Columns.imageURL.set(to: episode.imageURL)
                        ])
                }
            }
        }
    }
}
