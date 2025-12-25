import Brute
import Core
import SwiftUI

struct PodcastDetailView: View {
    
    @Environment(\.bruteContext) private var context
    
    let podcast: Podcast
    let isLoading: Bool
    
    let onPlay: (Int) -> Void
    let onRefresh: @Sendable () async -> Void
    
    var body: some View {
        BruteStyle {
            ScrollView {
                LazyVStack(spacing: context.dimen.paddingMedium) {
                    DisclosureGroup(
                        content: {
                            Text(podcast.description.htmlStripped)
                        },
                        label: {
                            VStack(alignment: .leading, spacing: context.dimen.paddingSmall) {
                                Text(podcast.title)
                                    .font(context.font.title)
                                Text("\(podcast.episodes?.count ?? 0) episodes")
                                    .font(context.font.caption)
                            }
                        }
                    )
                    
                    if let episodes = podcast.episodes {
                        ForEach(episodes.indices) { index in
                            EpisodeCard(
                                episode: episodes[index],
                                fallbackImageURL: podcast.imageURL,
                                onPlay: { onPlay(index) }
                            ).id(episodes[index].id)
                        }
                    }
                }
                .padding(context.dimen.paddingMedium)
            }
            .refreshable(action: onRefresh)
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
            description: "Haha funny",
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
            ]
        ),
        isLoading: false,
        onPlay: { _ in },
        onRefresh: {  }
    )
}
