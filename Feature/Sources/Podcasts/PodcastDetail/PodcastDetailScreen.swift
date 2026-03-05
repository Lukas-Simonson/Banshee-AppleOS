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
            episodes: viewModel.episodes,
            isLoading: viewModel.isLoading,
            order: $viewModel.sortOrder,
            onPlay: viewModel.play,
            onToggleComplete: viewModel.toggleCompletion,
            onEditConfig: viewModel.navigateToEditConfig,
            onRefresh: { await viewModel.refresh(force: true) },
            onNavigateBack: viewModel.navigateBack
        )
    }
}
