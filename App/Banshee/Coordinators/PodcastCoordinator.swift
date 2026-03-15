import Core
import Foundation
import Observation
import Podcasts
import Episodes
import SwiftUI

@Observable
final class PodcastCoordinator {
    var path = NavigationPath()
}

extension PodcastCoordinator: PodcastNavigationContract, EpisodeNavigationContract {
    func navigateToDetail(for podcast: Podcast) {
        path.append(PodcastDetailDestination(podcast: podcast))
    }
    
    func navigateToEditConfig(for podcast: Podcast) {
        path.append(EditPodcastConfigDestination(podcast: podcast))
    }
    
    func navigateToEditConfig(for episode: Episode) {
        path.append(EditEpisodeConfigDestination(episode: episode))
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
    
    struct EditPodcastConfigDestination: Identifiable, Destination {
        var id: UUID { podcast.id }
        let podcast: Podcast
    }
    
    struct EditEpisodeConfigDestination: Identifiable, Destination {
        var id: UUID { episode.id }
        let episode: Episode
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
                    .navigationDestination(for: EditPodcastConfigDestination.self) { destination in
                        PodcastConfigScreen(app.scaffold.podcast(), podcast: destination.podcast)
                    }
                    .navigationDestination(for: EditEpisodeConfigDestination.self) { destination in
                        EpisodeConfigScreen(app.scaffold.episode(), episode: destination.episode)
                    }
            }
        }
    }
}
