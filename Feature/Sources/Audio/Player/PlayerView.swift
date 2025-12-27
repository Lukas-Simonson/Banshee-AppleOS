import Brute
import Core
import SharedUI
import SwiftUI

public struct PlayerView: View {
    
    @State var viewModel: PlayerVM
    
    public init(_ scaffold: AudioScaffoldContract) {
        viewModel = PlayerVM(scaffold)
    }
    
    public var body: some View {
        MiniPlayerView(
            state: viewModel.state,
            onPlay: viewModel.play,
            onPause: viewModel.pause
        )
        .onTapGesture {
            viewModel.isPlayerExpanded = true
        }
        .sheet(isPresented: $viewModel.isPlayerExpanded) {
            FullPlayerView(
                state: viewModel.state,
                current: Binding(
                    get: { viewModel.state?.current ?? 0 },
                    set: { viewModel.seek(to: $0) }
                ),
                onPause: viewModel.pause,
                onPlay: viewModel.play,
                onPrevious: viewModel.prev,
                onNext: viewModel.next,
                onSkipBackward: viewModel.skipBackward,
                onSkipForward: viewModel.skipForward
            )
        }
    }
}
