import Core
import SwiftUI

public struct EpisodeConfigScreen: View {
    
    @State private var viewModel: EpisodeConfigVM
    
    public init(_ scaffold: EpisodeScaffoldContract, episode: Episode) {
        self.viewModel = EpisodeConfigVM(scaffold, episode: episode)
    }
    
    public var body: some View {
        EpisodeConfigView(
            isLoading: viewModel.isLoading,
            episode: viewModel.episode,
            config: $viewModel.config,
            onSave: viewModel.save,
            onNavigateBack: viewModel.navigateBack
        )
    }
}
