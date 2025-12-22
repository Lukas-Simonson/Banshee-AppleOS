import Business
import Cobweb
import Core
import Foundation

public struct CobwebRemotePodcastDataSource: RemotePodcastDataSourceContract {
    
    public init() {}
    
    public func getPodcasts(baseURL: String, token: String) async throws(RemotePodcastDataSourceError) -> [Podcast] {
        do {
            return try await Cobweb.URL.using(baseURL: baseURL)
                .path("/api/podcasts")
                .get()
                .responseBody(as: [PodcastDTO].self)
                .map { $0.toCore() }
        } catch is Cobweb.URL.URLError {
            throw RemotePodcastDataSourceError.invalidURL
        } catch is Cobweb.HTTP.Request.ResponseError {
            throw RemotePodcastDataSourceError.unexpectedResponse
        } catch {
            throw RemotePodcastDataSourceError.unexpected
        }
    }
}
