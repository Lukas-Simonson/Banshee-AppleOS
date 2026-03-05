import Brute
import Core
import SharedUI
import SwiftUI

struct SettingsView: View {
    
    @Environment(\.bruteContext) private var context
    @Environment(\.userRole) private var userRole
    
    @State private var userType = User.Role.user
    @State private var sections = Sections()
    
    @Binding var settings: Settings

    let onCreateUser: (User.Role) -> Void
    let onLogout: () -> Void

    var body: some View {
        BruteStyle {
            ScrollView {
                VStack(spacing: context.dimen.paddingMedium) {
                    themeSelection
                    adminSection
                    userSection
                }
                .padding(context.dimen.paddingMedium)
            }
        }
    }
    
    private var themeSelection: some View {
        DisclosureGroup("Theme", isExpanded: $sections.theme) {
            BrutePicker(selection: $settings.theme) {
                ForEach(Settings.Theme.allCases, id: \.self) { theme in
                    Text(theme.rawValue.capitalized)
                }
            }
        }
    }

    private var userSection: some View {
        DisclosureGroup("User", isExpanded: $sections.user) {
            Button(action: onLogout) {
                Text("Logout")
                    .bold()
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    @ViewBuilder
    private var adminSection: some View {
        if userRole == .admin {
            DisclosureGroup("Admin", isExpanded: $sections.admin) {
                VStack(spacing: context.dimen.paddingMedium) {
                    BrutePicker(selection: $userType) {
                        Text("User")
                            .tag(User.Role.user)
                        
                        Text("Admin")
                            .tag(User.Role.admin)
                    }
                    
                    Button(action: { onCreateUser(userType) }) {
                        Text("Create \(userType.rawValue.capitalized)")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

extension SettingsView {
    struct Sections {
        var theme = true
        var user = true
        var admin = true
    }
}

#Preview {
    
    @Previewable @State var settings = Settings.default
    
    SettingsView(
        settings: $settings,
        onCreateUser: { _ in },
        onLogout: {}
    )
    .environment(\.userRole, .admin)
}
