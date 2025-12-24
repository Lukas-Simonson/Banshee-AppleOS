import Foundation

extension JSONDecoder {
    func withISO8601() -> JSONDecoder {
        self.dateDecodingStrategy = .iso8601
        return self
    }
}
