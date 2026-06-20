import Brute
import Core
import SharedUI
import SwiftUI

struct EpisodeSettingsPopup: View {
    
    @Environment(\.bruteContext) private var context
    @Environment(\.userRole) private var userRole
    
    let onEditConfig: () -> Void
    
    var body: some View {
        BruteStyle {
            VStack(spacing: context.dimen.paddingMedium) {
                if userRole == .admin {
                    BruteSection("Admin") {
                        Button(
                            action: onEditConfig,
                            label: {
                                Text("Edit Episode Config")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        )
                    }
                }
            }
            .padding([.horizontal, .bottom], context.dimen.paddingMedium)
            .padding(.top, context.dimen.paddingLarge)
        }
    }
}

#Preview {
    EpisodeSettingsPopup(onEditConfig: { })
        .environment(\.userRole, .admin)
}
