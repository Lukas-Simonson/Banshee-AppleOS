import Brute
import Core
import SwiftUI

struct PodcastListView: View {
    
    @Environment(\.bruteContext) private var context
    
    let podcasts: [Podcast]
    let isLoading: Bool
    
    let onTapPodcast: (Podcast) -> Void
    let onRefresh: () async -> Void
    
    var body: some View {
        BruteStyle {
            if isLoading {
                ProgressView()
            } else {
                podcastGrid
            }
        }
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
        onRefresh: { }
    )
}
