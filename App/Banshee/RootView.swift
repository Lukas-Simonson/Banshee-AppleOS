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
            } else if let session = app.session {
                BottomNavigation(app: app)
                    .environment(\.userRole, session.user.role)
            } else {
                AuthCoordinator.Root(
                    coordinator: app.scaffold.authCoordinator()
                )
            }
        }
        .handleNotices(from: app.notices)
        .themed(with: app.settings.theme)
        .environment(app)
    }
}
