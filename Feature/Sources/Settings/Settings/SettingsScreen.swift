import SwiftUI

public struct SettingsScreen: View {
    
    @State private var viewModel: SettingsVM
    
    public init(_ scaffold: SettingsScaffoldContract) {
        self.viewModel = SettingsVM(scaffold)
    }
    
    public var body: some View {
        SettingsView(
            settings: Binding(
                get: { viewModel.settings },
                set: { viewModel.updateSettings($0) }
            ),
            onLogout: viewModel.logout
        )
    }
}
