import Core
import Foundation

struct PodcastDTO: Codable {
    let id: UUID
    let title: String
    let link: URL?
    let language: String
    let imageURL: URL?
    let description: String
    
    let config: PodcastConfigDTO?
    let episodes: [EpisodeDTO]?
}

extension PodcastDTO {
    func toCore() -> Podcast {
        Podcast(
            id: id,
            title: title,
            link: link,
            language: language,
            imageURL: imageURL,
            description: description,
            episodes: episodes?.map { $0.toCore() }
        )
    }
}
