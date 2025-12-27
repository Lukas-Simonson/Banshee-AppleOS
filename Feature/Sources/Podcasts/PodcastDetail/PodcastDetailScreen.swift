import Core
import SwiftUI

public struct PodcastDetailScreen: View {
    
    @State private var viewModel: PodcastDetailVM
    
    public init(_ scaffold: PodcastScaffoldContract, podcast: Podcast) {
        self.viewModel = PodcastDetailVM(scaffold, podcast: podcast)
    }
    
    public var body: some View {
        PodcastDetailView(
            podcast: viewModel.podcast,
            isLoading: viewModel.isLoading,
            onPlay: viewModel.play,
            onRefresh: viewModel.refresh,
            onNavigateBack: viewModel.navigateBack
        )
    }
}
