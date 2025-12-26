import Business
import Core
import Foundation
import GRDB

/// GRDB Record for persisting AudioProgress data.
struct AudioProgressRecord: Codable, FetchableRecord, PersistableRecord, Sendable {
    static let databaseTableName = "audioProgress"

    let episodeId: String
    let isCompleted: Bool
    let duration: Int
    let startedOn: Date
    let lastUpdated: Date
    let cachedAt: Date

    // Relationship to episode
    static let episode = belongsTo(EpisodeRecord.self, using: ForeignKey(["episodeId"]))

    /// Creates a record from a Business layer cached DTO.
    init(from cachedProgress: CachedAudioProgress, episodeId: UUID) {
        let progress = cachedProgress.progress
        self.episodeId = episodeId.uuidString
        self.isCompleted = progress.isCompleted
        self.duration = progress.duration
        self.startedOn = progress.startedOn
        self.lastUpdated = progress.lastUpdated
        self.cachedAt = cachedProgress.cachedAt
    }

    /// Converts to Business layer cached DTO.
    func toCached() -> CachedAudioProgress {
        CachedAudioProgress(
            progress: AudioProgress(
                isCompleted: isCompleted,
                duration: duration,
                startedOn: startedOn,
                lastUpdated: lastUpdated
            ),
            cachedAt: cachedAt
        )
    }
}
