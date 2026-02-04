import Brute
import Core
import SharedUI
import SwiftUI

struct PodcastConfigView: View {
    
    @Environment(\.bruteContext) private var context
    
    @State private var sections = Sections()
    @State private var imageURL = ""
    @State private var imageURLError: String?
    
    let isLoading: Bool
    let podcast: Podcast
    @Binding var config: PodcastConfig
    
    let onSave: () -> Void
    
    init(isLoading: Bool, podcast: Podcast, config: Binding<PodcastConfig>, onSave: @escaping () -> Void) {
        self.isLoading = isLoading
        self.podcast = podcast
        self.imageURL = config.wrappedValue.imageURL?.absoluteString ?? ""
        self._config = config
        self.onSave = onSave
    }
    
    var body: some View {
        BruteStyle {
            if isLoading {
                LoadingScreen()
            } else {
                ScrollView {
                    VStack(spacing: context.dimen.paddingMedium) {
                        titleSection
                        imageURLSection
                        descriptionSection
                        saveButton
                    }
                    .padding()
                }
            }
        }
    }
    
    private var titleSection: some View {
        DisclosureGroup("Title", isExpanded: $sections.title) {
            TextField("\(podcast.title)", text: $config.title.nilEmptyBinding())
                .textFieldStyle(.brute)
        }
    }
    
    private var imageURLSection: some View {
        DisclosureGroup("Image URL", isExpanded: $sections.imageURL) {
            VStack(alignment: .leading, spacing: context.dimen.paddingSmall) {
                if let imageURLError {
                    Text(imageURLError)
                        .foregroundStyle(Color.red)
                        .font(.footnote.bold())
                }
                
                TextField("\(podcast.imageURL?.absoluteString ?? "")", text: $imageURL)
                    .textFieldStyle(.brute)
                    .keyboardType(.URL)
                    .textContentType(.URL)
                    .textInputAutocapitalization(.never)
            }
        }
    }
    
    private var descriptionSection: some View {
        DisclosureGroup("Description", isExpanded: $sections.description) {
            TextField("\(podcast.description)", text: $config.description.nilEmptyBinding(), axis: .vertical)
                .lineLimit(5...10)
                .textFieldStyle(.brute)
        }
    }
    
    private var saveButton: some View {
        Button(
            action: {
                if !imageURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    guard let url = URL(string: imageURL) else {
                        imageURLError = "Invalid URL provided."
                        return
                    }
                    
                    config.imageURL = url
                }
                
                onSave()
            },
            label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
            }
        )
    }
}

extension Binding<String?> {
    func nilEmptyBinding() -> Binding<String> {
        Binding<String>(
            get: { wrappedValue ?? "" },
            set: { wrappedValue = $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : $0 }
        )
    }
}

extension PodcastConfigView {
    struct Sections {
        var title = true
        var imageURL = true
        var description = true
    }
}

#Preview {
    
    @Previewable @State var config = PodcastConfig(
        title: nil,
        imageURL: nil,
        description: nil,
        podcastID: UUID()
    )
    
    PodcastConfigView(
        isLoading: false,
        podcast: Podcast(
            id: UUID(),
            title: "Dungeons and Daddies",
            link: nil,
            language: "en",
            imageURL: URL(string: "https://assets.pippa.io/shows/61b7633a16956271a5e9503b/show-cover.jpg"),
            description: "Haha funny",
        ),
        config: $config,
        onSave: {  }
    )
}
