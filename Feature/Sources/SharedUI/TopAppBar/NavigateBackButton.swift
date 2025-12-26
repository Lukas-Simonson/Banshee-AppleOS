import Brute
import SwiftUI

public struct NavigateBackButton: View {
    
    let onNavigateBack: () -> Void
    
    public init(_ navigateBack: @escaping () -> Void) {
        self.onNavigateBack = navigateBack
    }
    
    public var body: some View {
        Button(
            "Back",
            systemImage: "arrowshape.backward.fill",
            action: onNavigateBack
        )
        .buttonStyle(.icon(size: .medium))
        .labelStyle(.iconOnly)
        
    }
}
