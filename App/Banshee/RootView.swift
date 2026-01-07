import Auth
import Brute
import Core
import NoticeMe
import Settings
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
        }
        .themed(with: app.settings.theme)
        .environment(app)
    }
}
