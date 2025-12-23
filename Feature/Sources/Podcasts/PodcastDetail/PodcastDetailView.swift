import Brute
import Core
import SwiftUI

struct PodcastDetailView: View {
    
    @Environment(\.bruteContext) private var context
    
    let podcast: Podcast
    let isLoading: Bool
    
    let onRefresh: @Sendable () async -> Void
    
    var body: some View {
        BruteStyle {
            ScrollView {
                LazyVStack(spacing: context.dimen.paddingMedium) {
                    
                    BruteCard {
                        Text(podcast.title)
                            .font(context.font.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(podcast.episodes?.count ?? 0) episodes")
                            .font(context.font.caption)
                        
                        Text(podcast.description.htmlStripped)
                    }
                    
                    ForEach(podcast.episodes ?? []) { episode in
                        EpisodeCard(episode: episode, fallbackImageURL: podcast.imageURL)
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
        onRefresh: {  }
    )
}
