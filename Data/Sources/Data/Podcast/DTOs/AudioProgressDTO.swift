import Core
import Foundation

public struct AudioProgressDTO: Codable {
    let isCompleted: Bool
    let duration: Int
    let startedOn: Date
    let lastUpdated: Date
}

extension AudioProgressDTO {
    func toCore() -> AudioProgress {
        AudioProgress(
            isCompleted: isCompleted,
            duration: duration,
            startedOn: startedOn,
            lastUpdated: lastUpdated,
        )
    }
}
