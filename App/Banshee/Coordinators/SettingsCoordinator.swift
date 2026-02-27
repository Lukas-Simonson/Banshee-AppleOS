import Core
import Foundation
import Observation
import Settings
import SwiftUI

@Observable
final class SettingsCoordinator {
    var path = NavigationPath()
}

extension SettingsCoordinator: SettingsNavigationContract {
    
    func navigateToCreateUser(for role: User.Role) {
        path.append(CreateUserDestination(role: role))
    }
    
    func navigateBack() {
        path.removeLast()
    }
    
    func showAlert(_ alert: CoreAlert) {
        AppCoordinator.shared.showAlert(alert)
    }
    
    func showError(_ error: CoreError) {
        AppCoordinator.shared.showError(error)
    }
    
    struct CreateUserDestination: Destination {
        let role: User.Role
    }
}

extension SettingsCoordinator {
    struct Root: View {
        
        @Environment(AppCoordinator.self) private var app
        
        @State var coordinator: SettingsCoordinator
        
        var body: some View {
            NavigationStack(path: $coordinator.path) {
                SettingsScreen(app.scaffold.settings())
                    .navigationDestination(for: CreateUserDestination.self) { destination in
                        UserRegistrationScreen(app.scaffold.settings(), role: destination.role)
                    }
            }
        }
    }
}
