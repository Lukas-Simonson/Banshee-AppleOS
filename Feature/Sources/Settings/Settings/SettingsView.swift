import Brute
import Core
import SharedUI
import SwiftUI

struct SettingsView: View {
    
    @Environment(\.bruteContext) private var context
    
    @State private var sections = Sections()
    
    @Binding var settings: Settings

    let onLogout: () -> Void

    var body: some View {
        BruteStyle {
            ScrollView {
                VStack(spacing: context.dimen.paddingMedium) {
                    themeSelection
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
}

extension SettingsView {
    struct Sections {
        var theme = true
        var user = true
    }
}

#Preview {
    
    @Previewable @State var settings = Settings.default
    
    SettingsView(
        settings: $settings,
        onLogout: {}
    )
}
