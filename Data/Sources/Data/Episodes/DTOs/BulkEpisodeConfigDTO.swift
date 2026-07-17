import Core
import Foundation

struct BulkEpisodeConfigDTO: Codable {
    let ids: Set<UUID>
    @Nullable var season: String?
    @Nullable var imageURL: URL?
}

extension BulkEpisodeConfig {
    func toDTO() -> BulkEpisodeConfigDTO {
        BulkEpisodeConfigDTO(
            ids: ids,
            season: Nullable(wrappedValue: season.value, omitted: season == .ignore),
            imageURL: Nullable(wrappedValue: imageURL.value, omitted: imageURL == .ignore)
        )
    }
}
