import Core
import SwiftUI

public struct BulkEpisodeConfigScreen: View {
    
    @State private var viewModel: BulkEpisodeConfigVM
    
    public init(_ scaffold: EpisodeScaffoldContract, episodeIDs: Set<UUID>) {
        self.viewModel = BulkEpisodeConfigVM(scaffold, episodeIDs: episodeIDs)
    }
    
    public var body: some View {
        BulkEpisodeConfigView(
            episodeCount: viewModel.episodeIDs.count,
            isLoading: viewModel.isLoading,
            onSave: viewModel.save,
            onNavigateBack: viewModel.navigateBack
        )
    }
}
