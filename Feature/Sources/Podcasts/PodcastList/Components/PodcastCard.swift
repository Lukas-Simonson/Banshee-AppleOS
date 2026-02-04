import Brute
import Core
import SharedUI
import SwiftUI

struct PodcastCard: View {
    
    @Environment(\.bruteContext) private var context
    
    let podcast: Podcast
    let onTap: () -> Void
    
    var body: some View {
        // BruteCard {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: context.dimen.paddingMedium) {
                
                CachedImage(for: podcast.imageURL)
                    .clipShape(RoundedRectangle(cornerRadius: context.dimen.cornerRadius))
                    .bruteStroked()
                
                Text(podcast.title)
                    .font(context.font.header)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .foregroundStyle(context.color.foreground)
        }
        .buttonStyle(.brute(fill: context.color.background))
    }
}

#Preview {
    BruteStyle {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)]) {
                ForEach(0..<8) { _ in
                    PodcastCard(
                        podcast: Podcast(
                            id: UUID(),
                            title: "Dungeons and Daddies",
                            link: nil,
                            language: "en",
                            imageURL: nil,
                            description: "Haha funny"
                        ),
                        onTap: { }
                    )
                }
            }
            .padding()
        }
    }
}
