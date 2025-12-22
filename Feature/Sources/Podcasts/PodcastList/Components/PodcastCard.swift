import Brute
import Core
import SwiftUI

struct PodcastCard: View {
    
    @Environment(\.bruteContext) private var context
    
    let podcast: Podcast
    let onTap: () -> Void
    
    var body: some View {
        // BruteCard {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: context.dimen.paddingMedium) {
                AsyncImage(
                    url: podcast.imageURL,
                    content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    },
                    placeholder: {
                        placeholderImage
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: context.dimen.cornerRadius))
                .bruteStroked()
                
                Text(podcast.title)
                    .font(context.font.header)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .buttonStyle(.brute(fill: context.color.background))
    }
    
    private var placeholderImage: some View {
        ZStack {
            Rectangle()
                .fill(context.color.accentBackground)
            
            Image(systemName: "mic.fill")
                .font(.system(size: 48))
                .foregroundStyle(context.color.accentForeground)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    BruteStyle {
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
