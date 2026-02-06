import Brute
import Core
import SharedUI
import SwiftUI

struct PodcastDetailView: View {
    
    @Environment(\.bruteContext) private var context
    @Environment(\.userRole) private var userRole
    
    let podcast: Podcast
    let episodes: [Episode]
    let isLoading: Bool
    
    let onPlay: (Episode) -> Void
    let onEditConfig: () -> Void
    let onRefresh: @Sendable () async -> Void
    let onNavigateBack: () -> Void
    
    var body: some View {
        BruteStyle {
            VStack(spacing: 0) {
                topAppBar
                
                if isLoading {
                    LoadingIndicator().frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: context.dimen.paddingMedium) {
                            podcastDetails
                            episodeDetails
                        }
                        .padding(context.dimen.paddingMedium)
                    }
                    .refreshable(action: onRefresh)
                    .navigationBarBackButtonHidden()
                }
            }
        }
    }
    
    @ViewBuilder
    private var topAppBar: some View {
        if userRole == .admin {
            TopAppBar(
                title: podcast.title,
                leading: {
                    NavigateBackButton(onNavigateBack)
                },
                trailing: {
                    Button("Settings", systemImage: "gearshape.fill", action: onEditConfig)
                        .buttonStyle(.icon(size: .medium))
                }
            )
        } else {
            TopAppBar(
                title: podcast.title,
                leading: {
                    NavigateBackButton(onNavigateBack)
                }
            )
        }
    }
    
    private var podcastDetails: some View {
        DisclosureGroup(
            content: {
                Text(podcast.description.htmlStripped)
            },
            label: {
                VStack(alignment: .leading, spacing: context.dimen.paddingSmall) {
                    Text(podcast.title)
                        .font(context.font.title)
                    Text("\(episodes.count) episodes")
                        .font(context.font.caption)
                }
            }
        )
    }
    
    private var episodeDetails: some View {
        ForEach(episodes) { episode in
            EpisodeCard(
                episode: episode,
                fallbackImageURL: podcast.imageURL,
                onPlay: { onPlay(episode) }
            )
        }
    }
}

#Preview {
    PodcastDetailView(
        podcast: Podcast(
            id: UUID(),
            title: "Dungeons and Daddies",
            link: nil,
            language: "en",
            imageURL: URL(string: "https://assets.pippa.io/shows/61b7633a16956271a5e9503b/show-cover.jpg"),
            description: "Haha funny"
        ),
        episodes: [
            Episode(
                id: UUID(),
                title: "A Man And His Handshake",
                pubDate: .distantPast,
                description: "The dads do a thing",
                imageURL: nil,
                season: "1",
                episode: 1,
                duration: nil,
                progress: nil
            )
        ],
        isLoading: false,
        onPlay: { _ in },
        onEditConfig: {  },
        onRefresh: {  },
        onNavigateBack: {  }
    )
    .environment(\.userRole, .user)
}
