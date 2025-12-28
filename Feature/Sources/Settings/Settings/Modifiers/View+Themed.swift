import Brute
import Core
import SwiftUI

public extension View {
    func themed(with theme: Settings.Theme) -> some View {
        let bruteTheme = switch theme {
            case .violet: BruteTheme.violet
            case .blue: BruteTheme.blue
            case .green: BruteTheme.green
            case .orange: BruteTheme.orange
            case .magenta: BruteTheme.magenta
            case .maroon: BruteTheme.maroon
        }
        
        return self.bruteTheme(bruteTheme)
    }
}
