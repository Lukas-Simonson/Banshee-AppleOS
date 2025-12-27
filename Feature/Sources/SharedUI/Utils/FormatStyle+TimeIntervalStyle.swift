import Foundation

public extension FormatStyle where Self == HoursMinutesSecondsTimeIntervalFormatter {
    static var timeInterval: Self { HoursMinutesSecondsTimeIntervalFormatter() }
}

public struct HoursMinutesSecondsTimeIntervalFormatter: FormatStyle {
    public func format(_ value: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = value >= 3600 ? [.hour, .minute, .second] : [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: TimeInterval(value)) ?? "00:00:00"
    }
}
