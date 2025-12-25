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
    }
}
