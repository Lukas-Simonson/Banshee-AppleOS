import Core
import Foundation

struct EpisodeDTO: Codable {
    let id: UUID
    let title: String
    let pubDate: Date
    let description: String
    let imageURL: URL?
    let season: String?
    let episode: Int?
}

extension EpisodeDTO {
    func toCore() -> Episode {
        Episode(
            id: id,
            title: title,
            pubDate: pubDate,
            description: description,
            imageURL: imageURL,
            season: season,
            episode: episode
        )
    }
}
