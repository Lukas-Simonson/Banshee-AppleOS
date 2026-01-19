import Core
import Foundation

public struct AudioProgressDTO: Codable {
    let isCompleted: Bool
    let watchTime: Int
    let startedOn: Date
    let lastUpdated: Date
}

extension AudioProgressDTO {
    func toCore() -> AudioProgress {
        AudioProgress(
            isCompleted: isCompleted,
            watchTime: watchTime,
            startedOn: startedOn,
            lastUpdated: lastUpdated,
        )
    }
}
