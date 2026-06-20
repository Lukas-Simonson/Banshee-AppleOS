import Brute
import Core
import SharedUI
import SwiftUI

struct EpisodeConfigView: View {
    
    @Environment(\.bruteContext) private var context
    
    @State private var sections = Sections()
    
    @State private var imageURL = ""
    @State private var imageURLError: String?
    
    @State private var episodeNumber = ""
    @State private var episodeNumberError: String?
    
    let isLoading: Bool
    let episode: Episode
    @Binding var config: EpisodeConfig
    
    let onSave: () -> Void
    let onNavigateBack: () -> Void
    
    var body: some View {
        BruteStyle {
            VStack(spacing: 0) {
                TopAppBar(
                    title: "Episode Config",
                    leading: { NavigateBackButton(onNavigateBack) }
                )
                
                if isLoading {
                    LoadingScreen()
                } else {
                    ScrollView {
                        VStack(spacing: context.dimen.paddingMedium) {
                            titleSection
                            seasonSection
                            episodeNumberSection
                            imageURLSection
                            descriptionSection
                            saveButton
                        }
                        .padding(context.dimen.paddingMedium)
                    }
                }
            }
            .navigationBarBackButtonHidden()
        }
    }
    
    private var titleSection: some View {
        DisclosureGroup("Title", isExpanded: $sections.title) {
            TextField("\(episode.title)", text: $config.title.nilEmptyBinding())
                .textFieldStyle(.brute)
        }
    }
    
    private var seasonSection: some View {
        DisclosureGroup("Season", isExpanded: $sections.season) {
            TextField("\(episode.season ?? "")", text: $config.season.nilEmptyBinding())
                .textFieldStyle(.brute)
        }
    }
    
    private var episodeNumberSection: some View {
        DisclosureGroup("Episode Number", isExpanded: $sections.episodeNumber) {
            VStack(alignment: .leading, spacing: context.dimen.paddingSmall) {
                if let episodeNumberError {
                    Text(episodeNumberError)
                        .foregroundStyle(Color.red)
                        .font(.footnote.bold())
                }
                
                TextField("\(episode.episode == nil ? "None" : "\(episode.episode!)")", text: $episodeNumber)
                    .textFieldStyle(.brute)
                    .keyboardType(.numberPad)
                    .textInputAutocapitalization(.never)
            }
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
                
                TextField("\(episode.imageURL?.absoluteString ?? "")", text: $imageURL)
                    .textFieldStyle(.brute)
                    .keyboardType(.URL)
                    .textContentType(.URL)
                    .textInputAutocapitalization(.never)
            }
        }
    }
    
    private var descriptionSection: some View {
        DisclosureGroup("Description", isExpanded: $sections.description) {
            TextField("\(episode.description)", text: $config.description.nilEmptyBinding(), axis: .vertical)
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
                } else {
                    config.imageURL = nil
                }
                
                if !episodeNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    guard let number = Int(episodeNumber) else {
                        episodeNumberError = "Invalid number provided."
                        return
                    }
                    
                    config.episode = number
                } else {
                    config.episode = nil
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

extension EpisodeConfigView {
    struct Sections {
        var title = true
        var season = true
        var episodeNumber = true
        var imageURL = true
        var description = true
    }
}

#Preview {
    
    @Previewable @State var config = EpisodeConfig(episodeID: UUID())
    
    EpisodeConfigView(
        isLoading: false,
        episode: Episode(
            id: UUID(),
            title: "A man and his handshake",
            pubDate: .distantPast,
            description: "The dads do a thing",
            imageURL: URL(string: "https://duckduckgo.com"),
            season: "1",
            episode: 1,
            duration: 1000,
            progress: nil
        ),
        config: $config,
        onSave: { },
        onNavigateBack: { }
    )
}
