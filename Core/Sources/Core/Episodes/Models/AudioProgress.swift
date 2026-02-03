import Foundation

public struct AudioProgress: Sendable {
    public let isCompleted: Bool
    public let watchTime: Int
    public let startedOn: Date
    public let lastUpdated: Date
    
    public init(isCompleted: Bool, watchTime: Int, startedOn: Date, lastUpdated: Date) {
        self.isCompleted = isCompleted
        self.watchTime = watchTime
        self.startedOn = startedOn
        self.lastUpdated = lastUpdated
    }
}
