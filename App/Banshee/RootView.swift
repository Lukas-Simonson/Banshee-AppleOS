import Auth
import Brute
import Core
import NoticeMe
import SharedUI
import Settings
import SwiftUI

struct RootView: View {
    
    @Environment(\.bruteContext) private var context
    
    @State private var app = AppCoordinator.shared
    
    var body: some View {
        BruteStyle {
            if app.isCheckingSession {
                LoadingScreen()
            } else if app.session != nil {
                BottomNavigation(app: app)
            } else {
                LoginScreen(app.scaffold.auth())
            }
        }
        .handleNotices(from: app.notices)
        .themed(with: app.settings.theme)
        .environment(app)
    }
}
