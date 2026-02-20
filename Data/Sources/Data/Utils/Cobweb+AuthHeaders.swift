import Cobweb
import Foundation

extension Cobweb.HTTP.Header {
    static func bearer(_ token: String) -> Self {
        .custom("Authorization", value: "Bearer \(token)")
    }
    
    static func basicAuth(username: String, password: String) -> Self {
        .custom(
            "Authorization",
            value: "Basic " + Data("\(username):\(password)".utf8).base64EncodedString()
        )
    }
}
