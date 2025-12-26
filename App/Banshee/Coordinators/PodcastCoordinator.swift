import Core
import Foundation
import Observation
import Podcasts
import SwiftUI

@Observable
final class PodcastCoordinator {
    var path = NavigationPath()
}

extension PodcastCoordinator: PodcastNavigationContract {
    func navigateToDetail(for podcast: Podcast) {
        path.append(PodcastDetailDestination(podcast: podcast))
    }

    func navigateBack() {
        path.removeLast()
    }

    func showError(_ error: CoreError) {
        AppCoordinator.shared.showError(error)
    }
    
    struct PodcastDetailDestination: Identifiable, Destination {
        var id: UUID { podcast.id }
        let podcast: Podcast
    }
}

extension PodcastCoordinator {
    struct Root: View {
        
        @Environment(AppCoordinator.self) private var app
        
        @State var coordinator: PodcastCoordinator
        
        var body: some View {
            NavigationStack(path: $coordinator.path) {
                PodcastListScreen(app.scaffold.podcast())
                    .navigationDestination(for: PodcastDetailDestination.self) { destination in
                        PodcastDetailScreen(app.scaffold.podcast(), podcast: destination.podcast)
                    }
            }
        }
    }
}
