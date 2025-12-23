import Auth
import Brute
import Core
import NoticeMe
import Podcasts
import SwiftUI

struct RootView: View {
    
    @State private var app = AppCoordinator.shared
    
    var body: some View {
        NoticeHandler(app.notices) {
            Group {
                if app.isCheckingSession {
                    
                } else if app.session != nil {
                    // PodcastListScreen(app.scaffold.podcast())
                    PodcastCoordinator.Root(coordinator: app.scaffold.podcastCoordinator())
                } else {
                    LoginScreen(app.scaffold.auth())
                }
            }
            .bruteTheme(.violet)
            .environment(app)
        }
    }
}
