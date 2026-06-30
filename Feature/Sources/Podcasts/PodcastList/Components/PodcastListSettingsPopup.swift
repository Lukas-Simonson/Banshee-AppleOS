import Brute
import Core
import SharedUI
import SwiftUI

struct PodcastListSettingsPopup: View {
    
    @Environment(\.bruteContext) private var context
    @Environment(\.userRole) private var userRole
    
    @State private var rssFeedURL: URL = URL(string: "//")!
    @State private var downloadMode: DownloadMode = .new
    
    let onAddFeed: (URL, DownloadMode) -> Void
    
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
                            
                            VStack(alignment: .leading, spacing: context.dimen.paddingSmall) {
                                Text("Automatically Download:")
                                BrutePicker(selection: $downloadMode) {
                                    Text("New")
                                        .tag(DownloadMode.new)
                                    Text("New & Existing")
                                        .tag(DownloadMode.newAndExisting)
                                    Text("None")
                                        .tag(DownloadMode.none)
                                }
                            }
                            
                            Button(
                                action: {
                                    onAddFeed(rssFeedURL, downloadMode)
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
        onAddFeed: { _, _ in }
    )
    .environment(\.userRole, .admin)
}
