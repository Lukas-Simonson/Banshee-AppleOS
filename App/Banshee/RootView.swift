import Auth
import Core
import NoticeMe
import SwiftUI

struct RootView: View {
    
    @State private var app = AppCoordinator.shared
    
    var body: some View {
        NoticeHandler(app.notices) {
            Group {
                if app.isCheckingSession {
                    
                } else if let session = app.session {
                    VStack {
                        Text("Welcome to Banshee")
                        Text("\(session.user.username)")
                        Button("Logout") {
                            Task {
                                try await app.scaffold.auth().repository().logout()
                            }
                        }
                    }
                } else {
                    LoginScreen(app.scaffold.auth())
                }
            }
        }
    }
}
