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
                case .playing, .paused: player(with: state)
                default: EmptyView()
            }
        }
    }
    
    private func player(with state: AudioPlayerState) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: context.dimen.paddingSmall) {
                CachedImage(for: state.imageURL)
                    .frame(maxHeight: 50)
                    .bruteClipped()
                    .bruteStroked()
                
                VStack(alignment: .leading, spacing: context.dimen.paddingSmall) {
                    Text(state.title)
                        .lineLimit(1)
                    
                    Text("\(state.current, format: .timeInterval) / \(state.duration, format: .timeInterval)")
                        .font(context.font.caption)
                }
                
                Spacer()
                
                switch state.mode {
                    case .playing:
                        Button("Pause", systemImage: "pause.fill", action: onPause)
                        
                    case .paused:
                        Button("Play", systemImage: "play.fill", action: onPlay)
                        
                    default: EmptyView()
                }
            }
            .labelStyle(.iconOnly)
            .padding(context.dimen.paddingMedium)
            
            Rectangle()
                .fill(context.color.border)
                .frame(height: context.dimen.borderWidth)
        }
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
