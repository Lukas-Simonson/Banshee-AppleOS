import Brute
import Core
import SharedUI
import SwiftUI

struct EpisodeCard: View {
    
    @Environment(\.bruteContext) private var context
    
    let episode: Episode
    let fallbackImageURL: URL?
    
    var body: some View {
        BruteCard {
            HStack(alignment: .top, spacing: context.dimen.paddingSmall) {

                CachedImage(for: episode.imageURL ?? fallbackImageURL)
                    .frame(maxWidth: 75)
                    .clipShape(RoundedRectangle(cornerRadius: context.dimen.cornerRadius))
                    .bruteStroked()
                
                VStack(alignment: .leading, spacing: context.dimen.paddingSmall) {
                    Text(episode.title)
                        .font(context.font.header)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(episode.description.htmlStripped)
                        .lineLimit(2)
                }
            }
        }
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
                episode: 1,
                duration: nil,
                progress: nil
            ),
            fallbackImageURL: nil
        )
        .padding()
    }
}
