import Foundation

public struct AudioProgress: Sendable {
    let isCompleted: Bool
    let duration: Int
    let startedOn: Date
    let lastUpdated: Date
    
    public init(isCompleted: Bool, duration: Int, startedOn: Date, lastUpdated: Date) {
        self.isCompleted = isCompleted
        self.duration = duration
        self.startedOn = startedOn
        self.lastUpdated = lastUpdated
    }
}
