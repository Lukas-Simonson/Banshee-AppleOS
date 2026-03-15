import Core
import Foundation

struct EpisodeConfigDTO: Codable {
    let title: String?
    let description: String?
    let imageURL: URL?
    let season: String?
    let episode: Int?
    let episodeID: UUID?
}

extension EpisodeConfig {
    func toDTO() -> EpisodeConfigDTO {
        EpisodeConfigDTO(
            title: title,
            description: description,
            imageURL: imageURL,
            season: season,
            episode: episode,
            episodeID: episodeID
        )
    }
}

extension EpisodeDTO {
    func toCoreWithConfig() -> (Episode, EpisodeConfig) {
        let config = EpisodeConfig(
            title: config?.title,
            description: config?.description,
            imageURL: config?.imageURL,
            season: config?.season,
            episode: config?.episode,
            episodeID: id
        )
        
        return (toCore(), config)
    }
}
