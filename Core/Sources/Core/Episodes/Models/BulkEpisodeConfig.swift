import Foundation

public struct BulkEpisodeConfig: Sendable {
    public var ids: Set<UUID>
    public var season: ConfigValue<String>
    public var imageURL: ConfigValue<URL>
    
    public init(ids: Set<UUID>, season: ConfigValue<String>, imageURL: ConfigValue<URL>) {
        self.ids = ids
        self.season = season
        self.imageURL = imageURL
    }
}
