import Brute
import Core
import SharedUI
import SwiftUI

struct PodcastListSettingsPopup: View {
    
    @Environment(\.bruteContext) private var context
    @Environment(\.userRole) private var userRole
    
    @State private var rssFeedURL: URL = URL(string: "//")!
    
    let onAddFeed: (URL) -> Void
    
    var body: some View {
        BruteStyle {
            VStack {
                if userRole == .admin {
                    BruteSection("Admin") {
                        VStack(spacing: context.dimen.paddingSmall) {
                            TextField("RSS Feed URL:", value: $rssFeedURL, format: .url)
                                .textFieldStyle(.brute)
                                .keyboardType(.URL)
                                .textContentType(.URL)
                                .textInputAutocapitalization(.never)
                            
                            Button(
                                action: {
                                    onAddFeed(rssFeedURL)
                                },
                                label: {
                                    Text("Add RSS Feed")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            )
                        }
                    }
                }
            }
            .padding([.horizontal, .bottom], context.dimen.paddingMedium)
            .padding(.top, context.dimen.paddingLarge)
        }
    }
}

#Preview {
    PodcastListSettingsPopup(
        onAddFeed: { _ in }
    )
    .environment(\.userRole, .admin)
}
