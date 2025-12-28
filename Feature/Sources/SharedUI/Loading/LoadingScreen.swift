import Brute
import SwiftUI

public struct LoadingScreen: View {
    
    public init() {}
    
    public var body: some View {
        BruteStyle {
            LoadingIndicator()
        }
    }
}

#Preview {
    LoadingScreen()
}
