import Brute
import Core
import SharedUI
import SwiftUI

struct EpisodeCard: View {
    
    @Environment(\.bruteContext) private var context
    
    let episode: Episode
    let fallbackImageURL: URL?
    
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
                .lineLimit(2)
            
            HStack(alignment: .center, spacing: context.dimen.paddingSmall) {
                Button("Play", systemImage: "play.fill") {
                    // TODO
                }
                
                Button("isCompleted", systemImage: isCompleted ? "checkmark" : "checkmark") {
                    // TODO
                }
                .buttonStyle(.brute(fill: isCompleted ? .green : .white))
            }
            .font(context.font.header)
            .labelStyle(.iconOnly)
            
            if !isCompleted, let duration = episode.duration, let progress = episode.progress?.duration {
                ProgressView(value: Double(progress) / Double(duration))
            }
        }
    }
}

extension FormatStyle where Self == HoursMinutesSecondsTimeIntervalFormatter {
    static var timeInterval: Self { HoursMinutesSecondsTimeIntervalFormatter() }
}

struct HoursMinutesSecondsTimeIntervalFormatter: FormatStyle {
    func format(_ value: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        
        return formatter.string(from: TimeInterval(value)) ?? "00:00:00"
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
                fallbackImageURL: nil
            )
            .padding()
        }
    }
}
