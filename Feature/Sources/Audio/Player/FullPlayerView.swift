import Brute
import Core
import SharedUI
import SwiftUI

struct FullPlayerView: View {

    @Environment(\.bruteContext) private var context

    var state: AudioPlayerState?
    @Binding var current: Int
    
    let onPause: () -> Void
    let onPlay: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onSkipBackward: () -> Void
    let onSkipForward: () -> Void

    var body: some View {
        BruteStyle {
            VStack(spacing: context.dimen.paddingLarge) {
                CachedImage(for: state?.imageURL)
                    .frame(maxWidth: 300)
                    .brutalized()
                
                Text(state?.title ?? "")
                    .font(context.font.title)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: context.dimen.paddingSmall) {
                    SeekSlider(
                        value: $current,
                        in: 0...(state?.duration ?? 1)
                    )
                    
                    HStack {
                        Text(state?.current ?? 0, format: .timeInterval)
                        Spacer()
                        Text(state?.duration ?? 0, format: .timeInterval)
                    }
                    .font(context.font.caption)
                    .padding(.horizontal, 10)
                }
                
                HStack(alignment: .center, spacing: context.dimen.paddingMedium) {
                    
                    Button(
                        "Skip Backward",
                        systemImage: "arrow.trianglehead.counterclockwise",
                        action: onSkipBackward
                    )
                    .buttonStyle(
                        .icon(
                            size: .small,
                            background: context.color.neutralBackground,
                            foreground: context.color.neutralForeground
                        )
                    )
                    
                    Button("Previous", systemImage: "backward.end.fill", action: onPrevious)
                    
                    Button(
                        state?.mode == .playing ? "Pause" : "Play",
                        systemImage: state?.mode == .playing ? "pause.fill" : "play.fill",
                        action: state?.mode == .playing ? onPause : onPlay
                    )
                    .buttonStyle(.icon(size: .large))
                    
                    Button("Previous", systemImage: "forward.end.fill", action: onPrevious)
                    
                    Button(
                        "Skip Forward",
                        systemImage: "arrow.trianglehead.clockwise",
                        action: onSkipForward
                    )
                    .buttonStyle(
                        .icon(
                            size: .small,
                            background: context.color.neutralBackground,
                            foreground: context.color.neutralForeground
                        )
                    )
                }
                .buttonStyle(
                    .icon(
                        size: .medium,
                        background: context.color.neutralBackground,
                        foreground: context.color.neutralForeground
                    )
                )
            }
            .padding(context.dimen.paddingMedium)
        }
    }
}

#Preview {
    FullPlayerView(
        state: AudioPlayerState(
            title: "A Man And His Handshake",
            imageURL: URL(string: "https://assets.pippa.io/shows/61b7633a16956271a5e9503b/show-cover.jpg"),
            current: 100,
            duration: 5000,
            queueSize: 0,
            queuePosition: 0,
            mode: .paused
        ),
        current: .constant(100),
        onPause: {},
        onPlay: {},
        onPrevious: {},
        onNext: {},
        onSkipBackward: {},
        onSkipForward: {}
    )
}
