import Foundation

public struct AudioProgress: Sendable {
    public let isCompleted: Bool
    public let duration: Int
    public let startedOn: Date
    public let lastUpdated: Date
    
    public init(isCompleted: Bool, duration: Int, startedOn: Date, lastUpdated: Date) {
        self.isCompleted = isCompleted
        self.duration = duration
        self.startedOn = startedOn
        self.lastUpdated = lastUpdated
    }
}
