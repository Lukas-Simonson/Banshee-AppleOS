import Core
import SwiftUI

public struct UserRegistrationScreen: View {
    
    @State private var viewModel: UserRegistrationVM
    
    public init(_ scaffold: SettingsScaffoldContract, role: User.Role) {
        self.viewModel = UserRegistrationVM(scaffold, for: role)
    }
    
    public var body: some View {
        UserRegistrationView(
            role: viewModel.role,
            isLoading: viewModel.isLoading,
            name: $viewModel.name,
            username: $viewModel.username,
            email: $viewModel.email,
            password: $viewModel.password,
            onNavigateBack: viewModel.navigateBack,
            onCreateUser: viewModel.createUser
        )
    }
}
