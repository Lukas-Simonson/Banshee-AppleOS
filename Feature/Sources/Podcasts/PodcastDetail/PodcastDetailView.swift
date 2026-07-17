import Brute
import Core
import SharedUI
import SwiftUI

struct PodcastDetailView: View {
    
    @Environment(\.bruteContext) private var context
    
    @State private var bulkSelect = false
    @State private var showSettings = false
    @State private var episodeSettings: Episode?
    @State private var podcastDetailsID = UUID()
    
    let podcast: Podcast
    let episodes: [Episode]
    let isLoading: Bool
    
    @Binding var selectedIDs: Set<UUID>
    @Binding var order: Episode.Order
    @Binding var scroll: UUID?
    
    let onPlay: (Episode) -> Void
    let onToggleComplete: (Episode) -> Void
    let onEditConfig: () -> Void
    let onEditEpisodeConfig: (Episode) -> Void
    let onBulkEpisodeConfig: () -> Void
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
                        .safeAreaInset(edge: .bottom) {
                            if bulkSelect {
                                bulkEditBar
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
                    },
                    onBulkEdit: {
                        showSettings = false
                        bulkSelect = true
                    }
                )
                .autoDetent()
            }
            .sheet(item: $episodeSettings) { episode in
                EpisodeSettingsPopup(
                    onEditConfig: {
                        episodeSettings = nil
                        onEditEpisodeConfig(episode)
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
            HStack(spacing: context.dimen.paddingSmall) {
                if bulkSelect {
                    Toggle(
                        "",
                        isOn: Binding(
                            get: { selectedIDs.contains(episode.id) },
                            set: { toggled in
                                if toggled {
                                    selectedIDs.insert(episode.id)
                                } else {
                                    selectedIDs.remove(episode.id)
                                }
                            }
                        )
                    )
                    .accessibilityLabel("Select")
                    .toggleStyle(.bruteCheckbox)
                    .frame(height: 50, alignment: .center) // MARK: Needed due to a toggle height bug.
                }
                
                EpisodeCard(
                    episode: episode,
                    isSelectionMode: bulkSelect,
                    fallbackImageURL: podcast.imageURL,
                    onPlay: { onPlay(episode) },
                    onToggleComplete: { onToggleComplete(episode) },
                    onOptions: { episodeSettings = episode }
                )
            }
            .id(episode.id)
            .padding(.horizontal, context.dimen.paddingMedium)
        }
//        .animation(.default, value: bulkSelect)
    }
    
    private var bulkEditBar: some View {
        HStack {
            Button(
                action: {
                    selectedIDs = []
                    bulkSelect = false
                },
                label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
            )
            .buttonStyle(.brute(fill: .red))
            
            Button(
                action: onBulkEpisodeConfig,
                label: {
                    Text("Edit \(selectedIDs.count) episodes?")
                        .frame(maxWidth: .infinity)
                }
            )
        }
        .padding(context.dimen.paddingMedium)
    }
}

#Preview {
    
    @Previewable @State var selected = Set<UUID>()
    
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
                id: UUID(uuidString: "8E4ABF63-A63A-49E0-BAF6-A570F5D59818")!,
                title: "A Man And His Handshake",
                pubDate: .distantPast,
                description: "The dads do a thing",
                imageURL: nil,
                season: "1",
                episode: 1,
                duration: nil,
                progress: nil
            ),
            Episode(
                id: UUID(uuidString: "8E4ABF63-A63A-49E0-BAF6-A570F5D59819")!,
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
        selectedIDs: $selected,
        order: .constant(.title(asc: true)),
        scroll: .constant(nil),
        onPlay: { _ in },
        onToggleComplete: { _ in },
        onEditConfig: {  },
        onEditEpisodeConfig: { _ in },
        onBulkEpisodeConfig: {  },
        onRefresh: {  },
        onNavigateBack: {  }
    )
    .environment(\.userRole, .admin)
}
