import Brute
import Core
import SwiftUI

struct EpisodeCard: View {
    
    @Environment(\.bruteContext) private var context
    
    let episode: Episode
    let fallbackImageURL: URL?
    
    var body: some View {
        BruteCard {
            HStack(alignment: .top, spacing: context.dimen.paddingSmall) {
                AsyncImage(
                    url: episode.imageURL ?? fallbackImageURL,
                    content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    },
                    placeholder: {
                        placeholderImage
                    }
                )
                .frame(maxWidth: 75)
                .clipShape(RoundedRectangle(cornerRadius: context.dimen.cornerRadius))
                .bruteStroked()
                
                VStack(alignment: .leading, spacing: context.dimen.paddingSmall) {
                    Text(episode.title)
                        .font(context.font.header)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(episode.description)
                        .lineLimit(2)
                }
            }
        }
    }
    
    private var placeholderImage: some View {
        ZStack {
            Rectangle()
                .fill(context.color.accentBackground)
            
            Image(systemName: "mic.fill")
                .font(.system(size: 32))
                .foregroundStyle(context.color.accentForeground)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    BruteStyle {
        EpisodeCard(
            episode: Episode(
                id: UUID(),
                title: "A Man And His Handshake",
                pubDate: .distantPast,
                description: "The dads do a thing",
                imageURL: nil,
                season: "1",
                episode: 1
            ),
            fallbackImageURL: nil
        )
        .padding()
    }
}
