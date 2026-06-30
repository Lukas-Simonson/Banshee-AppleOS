import Brute
import Core
import SharedUI
import SwiftUI

struct PodcastListView: View {
    
    @Environment(\.bruteContext) private var context
    @Environment(\.userRole) private var userRole
    
    @State private var showSettings = false
    
    let podcasts: [Podcast]
    let isLoading: Bool
    
    let onTapPodcast: (Podcast) -> Void
    let onRefresh: @Sendable () async -> Void
    let onAddFeed: (URL, DownloadMode) -> Void
    
    var body: some View {
        BruteStyle {
            VStack(spacing: 0) {
                if userRole == .admin {
                    TopAppBar(
                        title: "Podcasts",
                        trailing: {
                            Button("Settings", systemImage: "gearshape.fill") {
                                showSettings = true
                            }
                            .buttonStyle(.icon(size: .medium))
                        }
                    )
                }
                
                if isLoading {
                    LoadingIndicator()
                } else if podcasts.isEmpty {
                    noPodcasts
                } else {
                    podcastGrid
                }
            }
            .sheet(isPresented: $showSettings) {
                PodcastListSettingsPopup(
                    onAddFeed: { url, downloadMode in
                        onAddFeed(url, downloadMode)
                        showSettings = false
                    }
                )
                .autoDetent()
            }
        }
    }
    
    private var noPodcasts: some View {
        ContentUnavailableView(
            "No Podcasts",
            systemImage: "microphone.slash.fill",
            description: Text("No podcasts available")
        )
    }
    
    private var podcastGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 150, maximum: 200), spacing: context.dimen.paddingMedium)
                ],
                spacing: context.dimen.paddingMedium
            ) {
                ForEach(podcasts) { podcast in
                    PodcastCard(
                        podcast: podcast,
                        onTap: { onTapPodcast(podcast) }
                    )
                }
            }
            .padding(context.dimen.paddingMedium)
        }
        .refreshable(action: onRefresh)
    }
}

#Preview {
    PodcastListView(
        podcasts: [
            Podcast(
                id: UUID(),
                title: "Dungeons and Daddies",
                link: nil,
                language: "en",
                imageURL: URL(string: "https://assets.pippa.io/shows/61b7633a16956271a5e9503b/show-cover.jpg"),
                description: "Haha funny"
            ),
            Podcast(
                id: UUID(),
                title: "The Adventure Zone",
                link: nil,
                language: "en",
                imageURL: URL(string: "https://maximumfun.org/wp-content/uploads/2019/03/Adventure-Zone-The-Season-9-Royale-400x400.jpg"),
                description: "Haha funny"
            ),
        ],
        isLoading: false,
        onTapPodcast: { _ in },
        onRefresh: { },
        onAddFeed: { _, _ in }
    )
    .environment(\.userRole, .admin)
}
