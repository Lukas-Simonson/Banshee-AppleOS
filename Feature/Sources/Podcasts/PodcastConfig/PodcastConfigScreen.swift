import Core
import SwiftUI

public struct PodcastConfigScreen: View {
    
    @State private var viewModel: PodcastConfigVM
    
    init(_ scaffold: PodcastScaffoldContract, podcast: Podcast) {
        self.viewModel = PodcastConfigVM(scaffold, podcast: podcast)
    }
    
    public var body: some View {
        PodcastConfigView(
            isLoading: viewModel.isLoading,
            podcast: viewModel.podcast,
            config: $viewModel.config,
            onSave: {
                fatalError("On Save not implemented")
            }
        )
    }
}
