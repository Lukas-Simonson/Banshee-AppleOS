import Core
import Foundation

struct PodcastDTO: Codable {
    let id: UUID
    let title: String
    let link: URL?
    let language: String
    let imageURL: URL?
    let description: String
}

extension PodcastDTO {
    func toCore() -> Podcast {
        Podcast(
            id: id,
            title: title,
            link: link,
            language: language,
            imageURL: imageURL,
            description: description
        )
    }
}
