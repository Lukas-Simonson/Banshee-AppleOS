import Auth
import Core
import Episodes
import Foundation
import Observation
import SwiftUI

@Observable
final class AuthCoordinator {
    var path = NavigationPath()
}

extension AuthCoordinator: AuthNavigationContract {
    func navigateHome() {
        // Handled automatically by the AppCoordinator
    }
    
    func navigateToSetup() {
        path.append(ServerSetupDestination())
    }
    
    func navigateBack() {
        path.removeLast()
    }
    
    func showError(_ error: Core.CoreError) {
        AppCoordinator.shared.showError(error)
    }
    
    struct ServerSetupDestination: Destination { }
}

extension AuthCoordinator {
    struct Root: View {
        @Environment(AppCoordinator.self) private var app
        @State var coordinator: AuthCoordinator
        
        var body: some View {
            NavigationStack(path: $coordinator.path) {
                LoginScreen(app.scaffold.auth())
                    .navigationDestination(for: ServerSetupDestination.self) { _ in
                        ServerSetupScreen(app.scaffold.auth())
                    }
            }
        }
    }
}
