import Brute
import Core
import SharedUI
import SwiftUI

struct MiniPlayerView: View {
    
    @Environment(\.bruteContext) var context
    
    let state: AudioPlayerState?
    
    let onPlay: () -> Void
    let onPause: () -> Void
    
    var body: some View {
        if let state {
            switch state.mode {
                case .playing, .paused, .loading: player(with: state)
                default: EmptyView()
            }
        }
    }
    
    private func player(with state: AudioPlayerState) -> some View {
        wrapper {
            HStack(spacing: context.dimen.paddingSmall) {
                CachedImage(for: state.imageURL)
                    .frame(maxHeight: 50)
                    .bruteClipped()
                    .bruteStroked()
                
                Group {
                    switch state.mode {
                        case .playing, .paused:
                            VStack(alignment: .leading, spacing: context.dimen.paddingSmall) {
                                Text(state.title)
                                    .lineLimit(1)
                                Text("\(state.current, format: .timeInterval) / \(state.duration, format: .timeInterval)")
                                    .font(context.font.caption)
                            }
                        case .loading:
                            ProgressView()
                                .progressViewStyle(.circular)
                        default: EmptyView()
                    }
                }
                .animation(.default, value: state.mode)
                
                Spacer()
                
                switch state.mode {
                    case .playing:
                        Button("Pause", systemImage: "pause.fill", action: onPause)
                            .buttonStyle(.icon(size: .medium))
                        
                    case .paused:
                        Button("Play", systemImage: "play.fill", action: onPlay)
                            .buttonStyle(.icon(size: .medium))
                        
                    default: EmptyView()
                }
            }
            .labelStyle(.iconOnly)
            .padding(context.dimen.paddingMedium)
        }
    }
    
    private func wrapper(for content: () -> some View) -> some View {
        VStack(spacing: 0) {
            content()
            BruteDivider()
        }
        .bruteThemeLeveled(by: 1)
    }
}

#Preview {
    BruteStyle {
        MiniPlayerView(
            state: AudioPlayerState(
                title: "A Man And His Handshake",
                imageURL: nil,
                current: 9093,
                duration: 10000,
                queueSize: 0,
                queuePosition: 0,
                mode: .paused
            ),
            onPlay: {  },
            onPause: {  }
        )
        .padding()
        .background()
    }
}
