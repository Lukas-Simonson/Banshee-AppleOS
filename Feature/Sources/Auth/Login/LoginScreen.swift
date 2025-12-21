import SwiftUI

public struct LoginScreen: View {
    @State private var viewModel: LoginVM
    
    public init(_ scaffold: AuthScaffoldContract) {
        self.viewModel = LoginVM(scaffold)
    }
    
    public var body: some View {
        LoginView(
            isLoading: viewModel.isLoading,
            loginEnabled: viewModel.isLoginEnabled,
            serverURL: $viewModel.serverURL,
            username: $viewModel.username,
            password: $viewModel.password,
            onLogin: viewModel.login
        )
    }
}
