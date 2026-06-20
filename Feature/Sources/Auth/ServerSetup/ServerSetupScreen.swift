import SwiftUI

public struct ServerSetupScreen: View {
    @State private var viewModel: ServerSetupVM
    
    public init(_ scaffold: AuthScaffoldContract) {
        self.viewModel = ServerSetupVM(scaffold)
    }
    
    public var body: some View {
        ServerSetupView(
            isLoading: viewModel.isLoading,
            baseURL: $viewModel.baseURL,
            name: $viewModel.name,
            username: $viewModel.username,
            email: $viewModel.email,
            password: $viewModel.password,
            onNavigateBack: viewModel.navigateBack,
            onCompleteSetup: viewModel.completeSetup
        )
    }
}
