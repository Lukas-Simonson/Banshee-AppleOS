import Cobweb

extension Cobweb.HTTP.Header {
    static func bearer(_ token: String) -> Self {
        .custom("Authorization", value: "Bearer \(token)")
    }
}
