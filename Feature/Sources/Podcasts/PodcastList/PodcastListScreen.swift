
import SwiftUI

public struct PodcastListScreen: View {
    
    @State private var viewModel: PodcastListVM
    
    public init(_ scaffold: PodcastScaffoldContract) {
        self.viewModel = PodcastListVM(scaffold)
    }
    
    public var body: some View {
        PodcastListView(
            podcasts: viewModel.podcasts,
            isLoading: viewModel.isLoading,
            onTapPodcast: viewModel.selectPodcast,
            onRefresh: viewModel.refresh
        )
    }
}
