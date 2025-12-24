
extension String {
    var htmlStripped: String {
        replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
}
