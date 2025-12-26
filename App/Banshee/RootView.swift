import Audio
import Auth
import Brute
import Core
import NoticeMe
import Podcasts
import SwiftUI

struct RootView: View {
    
    @Environment(\.bruteContext) private var context
    
    @State private var app = AppCoordinator.shared
    
    var body: some View {
        NoticeHandler(app.notices) {
            BruteStyle {
                if app.isCheckingSession {
                    
                } else if app.session != nil {
                    BottomNavigation(app: app)
                } else {
                    LoginScreen(app.scaffold.auth())
                }
            }
            .bruteTheme(.violet)
            .environment(app)
        }
    }
}
