import Brute
import Core
import SharedUI
import SwiftUI

struct EpisodeCard: View {
    
    @Environment(\.bruteContext) private var context
    
    let episode: Episode
    let fallbackImageURL: URL?
    
    let onPlay: () -> Void
    
    private var isCompleted: Bool {
        episode.progress?.isCompleted ?? false
    }
    
    var body: some View {
        BruteCard {
            HStack(alignment: .center, spacing: context.dimen.paddingSmall) {
                CachedImage(for: episode.imageURL ?? fallbackImageURL)
                    .frame(maxWidth: 75)
                    .bruteClipped()
                    .bruteStroked()
                
                VStack(alignment: .leading, spacing: context.dimen.paddingSmall) {
                    Text(episode.title)
                        .font(context.font.header)
                    
                    if let duration = episode.duration {
                        Text(duration, format: .timeInterval)
                            .font(context.font.caption)
                    }
                }
                
                Spacer()
            }
            
            Text(episode.description.htmlStripped)
                .lineLimit(3)
                .font(Font.caption)
            
            HStack(alignment: .center, spacing: context.dimen.paddingSmall) {
                Button("Play", systemImage: "play.fill", action: onPlay)
                    .buttonStyle(.icon(size: .small))
                
                Button("Is Completed", systemImage: "checkmark") {
                    // TODO
                }
                .buttonStyle(.icon(size: .small, background: isCompleted ? .green : .white, foreground: .black))
                
                Spacer()
                
                Button("Options", systemImage: "ellipsis") {
                    // TODO
                }
                .buttonStyle(.icon(size: .small, background: .white, foreground: .black))
            }
            .font(context.font.header)
            .labelStyle(.iconOnly)
            
            if !isCompleted, let duration = episode.duration, let progress = episode.progress?.duration {
                ProgressView(value: Double(progress) / Double(duration))
            }
        }
    }
}

#Preview {
    BruteStyle {
        ScrollView {
            EpisodeCard(
                episode: Episode(
                    id: UUID(),
                    title: "A Man And His Handshake",
                    pubDate: .distantPast,
                    description: "The dads do a thing, with a long description that can be used to show length changes.",
                    imageURL: nil,
                    season: "1",
                    episode: 1,
                    duration: 10000,
                    progress: AudioProgress(
                        isCompleted: false,
                        duration: 1000,
                        startedOn: .now,
                        lastUpdated: .now
                    )
                ),
                fallbackImageURL: nil,
                onPlay: { }
            )
            .padding()
        }
    }
}
