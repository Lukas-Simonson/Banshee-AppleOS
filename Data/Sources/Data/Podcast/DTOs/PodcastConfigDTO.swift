import Core
import Foundation

public struct PodcastConfigDTO: Codable {
    public let title: String?
    public let imageURL: URL?
    public let description: String?
    public let podcastID: UUID
}

extension PodcastConfig {
    func toDTO() -> PodcastConfigDTO {
        PodcastConfigDTO(
            title: title,
            imageURL: imageURL,
            description: description,
            podcastID: podcastID
        )
    }
}

extension PodcastDTO {
    func toCoreWithConfig() -> (Podcast, PodcastConfig) {
        let config = PodcastConfig(
            title: config?.title,
            imageURL: config?.imageURL,
            description: config?.description,
            podcastID: id
        )
        
        return (toCore(), config)
    }
}
