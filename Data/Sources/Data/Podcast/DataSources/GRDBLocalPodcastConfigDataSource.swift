import Business
import Core
import Foundation
import GRDB
import Logging

public struct GRDBLocalPodcastConfigDataSource: LocalPodcastConfigDataSourceContract {

    private let dbManager: DatabaseManager
    private let logger: Logger
    
    public init(dbManager: DatabaseManager, logger: Logger) {
        self.dbManager = dbManager
        self.logger = logger
    }
    
    public func updatePodcast(with config: PodcastConfig) async throws(CoreError) {
        try await CoreError.catchDatabase(performing: "Updating podcast config", logger: logger, feature: .podcasts) {
            try await dbManager.dbQueue.write { db in
                var assignments = [ColumnAssignment]()
                
                if let title = config.title {
                    assignments.append(PodcastRecord.Columns.title.set(to: title))
                }
                
                if let image = config.imageURL?.absoluteString {
                    assignments.append(PodcastRecord.Columns.imageURL.set(to: image))
                }
                
                if let description = config.description {
                    assignments.append(PodcastRecord.Columns.description.set(to: description))
                }
                
                guard !assignments.isEmpty else { return }
                
                try PodcastRecord
                    .filter(PodcastRecord.Columns.id == config.podcastID)
                    .updateAll(db, assignments)
                
            }
        }
    }
}
