import Logging

extension Logger {
    public func warning<E: Error>(_ message: Logger.Message, for error: E) {
        self.warning(message, metadata: [
            "error": "\(error)",
            "description": "\(error.localizedDescription)",
        ])
    }
    
    public func error<E: Error>(_ message: Logger.Message, for error: E) {
        self.error(message, metadata: [
            "error": "\(error)",
            "description": "\(error.localizedDescription)"
        ])
    }
}
