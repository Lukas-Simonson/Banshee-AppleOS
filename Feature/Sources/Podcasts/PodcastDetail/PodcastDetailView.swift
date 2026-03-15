import Brute
import Core
import SharedUI
import SwiftUI

struct PodcastDetailView: View {
    
    @Environment(\.bruteContext) private var context
    
    @State private var showSettings = false
    @State private var podcastDetailsID = UUID()
    
    let podcast: Podcast
    let episodes: [Episode]
    let isLoading: Bool
    
    @Binding var order: Episode.Order
    @Binding var scroll: UUID?
    
    let onPlay: (Episode) -> Void
    let onToggleComplete: (Episode) -> Void
    let onEditConfig: () -> Void
    let onEditEpisodeConfig: (Episode) -> Void
    let onRefresh: @Sendable () async -> Void
    let onNavigateBack: () -> Void
    
    var body: some View {
        BruteStyle {
            VStack(spacing: 0) {
                topAppBar
                
                if isLoading {
                    LoadingScreen()
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: context.dimen.paddingMedium) {
                                podcastDetails
                                episodeDetails
                            }
                            .padding(.vertical, context.dimen.paddingMedium)
                            .scrollTargetLayout()
                        }
                        .refreshable(action: onRefresh)
                        .scrollPosition(id: $scroll, anchor: .center)
                        .onChange(of: scroll) { oldValue, newValue in
                            if newValue == nil {
                                proxy.scrollTo(podcastDetailsID, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .sheet(isPresented: $showSettings) {
                PodcastDetailSettingsPopup(
                    order: $order,
                    onEditConfig: {
                        showSettings = false
                        onEditConfig()
                    }
                )
                .autoDetent()
            }
        }
    }
    
    @ViewBuilder
    private var topAppBar: some View {
        TopAppBar(
            title: podcast.title,
            leading: {
                NavigateBackButton(onNavigateBack)
            },
            trailing: {
                Button("Options", systemImage: "gearshape.fill") {
                    showSettings = !showSettings
                }
                .buttonStyle(.icon(size: .medium))
            }
        )
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
        .id(podcastDetailsID)
        .padding(.horizontal, context.dimen.paddingMedium)
    }
    
    private var episodeDetails: some View {
        ForEach(episodes) { episode in
            EpisodeCard(
                episode: episode,
                fallbackImageURL: podcast.imageURL,
                onPlay: { onPlay(episode) },
                onToggleComplete: { onToggleComplete(episode) },
                onOptions: { onEditEpisodeConfig(episode) }
            )
            .id(episode.id)
            .padding(.horizontal, context.dimen.paddingMedium)
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
        order: .constant(.title(asc: true)),
        scroll: .constant(nil),
        onPlay: { _ in },
        onToggleComplete: { _ in },
        onEditConfig: {  },
        onEditEpisodeConfig: { _ in },
        onRefresh: {  },
        onNavigateBack: {  }
    )
    .environment(\.userRole, .admin)
}
