import Brute
import Core
import SharedUI
import SwiftUI

struct BulkEpisodeConfigView: View {
    
    @Environment(\.bruteContext) private var context
    
    @State private var sections = Sections()
    
    @State private var imageConfig = ConfigMode.ignore
    @State private var imageURL = ""
    @State private var imageURLError: String?
    
    @State private var seasonConfig = ConfigMode.ignore
    @State private var season = ""
    
    let episodeCount: Int
    let isLoading: Bool
    
    let onSave: (ConfigValue<String>, ConfigValue<URL>) -> Void
    let onNavigateBack: () -> Void
    
    var body: some View {
        BruteStyle {
            VStack(spacing: 0) {
                TopAppBar(
                    title: "Edit \(episodeCount) Episodes",
                    leading: { NavigateBackButton(onNavigateBack) }
                )
                
                if isLoading {
                    LoadingScreen()
                } else {
                    ScrollView {
                        VStack(spacing: context.dimen.paddingMedium) {
                            seasonSection
                            imageURLSection
                            saveButton
                        }
                        .padding(context.dimen.paddingMedium)
                    }
                }
            }
        }
    }
    
    private var seasonSection: some View {
        DisclosureGroup("Season", isExpanded: $sections.season) {
            VStack(spacing: context.dimen.paddingSmall) {
                BrutePicker(selection: $seasonConfig) {
                    Text("No Change")
                        .tag(ConfigMode.ignore)
                    
                    Text("Reset")
                        .tag(ConfigMode.nullify)
                    
                    Text("Update")
                        .tag(ConfigMode.replace)
                }
                
                if seasonConfig == .replace {
                    TextField("Season:", text: $season)
                        .textFieldStyle(.brute)
                }
            }
        }
    }
    
    private var imageURLSection: some View {
        DisclosureGroup("Image URL", isExpanded: $sections.imageURL) {
            VStack(alignment: .leading, spacing: context.dimen.paddingSmall) {
                BrutePicker(selection: $imageConfig) {
                    Text("No Change")
                        .tag(ConfigMode.ignore)
                    
                    Text("Reset")
                        .tag(ConfigMode.nullify)
                    
                    Text("Update")
                        .tag(ConfigMode.replace)
                }
                
                if let imageURLError {
                    Text(imageURLError)
                        .foregroundStyle(Color.red)
                        .font(.footnote.bold())
                }
                
                if imageConfig == .replace {
                    TextField("Image URL:", text: $imageURL)
                        .textFieldStyle(.brute)
                }
            }
        }
    }
    
    private var saveButton: some View {
        Button(
            action: {
                if imageConfig == .replace {
                    guard let url = URL(string: imageURL) else {
                        imageURLError = "Invalid URL provided."
                        return
                    }
                    imageURLError = nil
                    onSave(seasonConfig.toConfigValue(with: season), imageConfig.toConfigValue(with: url))
                    return
                }
                
                onSave(seasonConfig.toConfigValue(with: season), imageConfig.toConfigValue(with: nil))
            },
            label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
            }
        )
    }
}

extension BulkEpisodeConfigView {
    struct Sections {
        var season = true
        var imageURL = true
    }
    
    enum ConfigMode {
        case ignore
        case nullify
        case replace
        
        func toConfigValue<T>(with input: T?) -> ConfigValue<T> {
            switch self {
                case .ignore:
                    return .ignore
                case .nullify:
                    return .nullify
                case .replace:
                    precondition(input != nil, "ConfigMode.replace must be provided a non-nil value.")
                    return .replace(input!)
            }
        }
    }
}

#Preview {
    BulkEpisodeConfigView(
        episodeCount: 42,
        isLoading: false,
        onSave: { _, _ in },
        onNavigateBack: { }
    )
}
