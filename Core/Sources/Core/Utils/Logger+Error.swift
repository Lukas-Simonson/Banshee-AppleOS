import Logging

extension Logger {
    public func warning(_ message: Logger.Message, for error: any Error) {
        self.warning(message, metadata: [
            "error": "\(error)",
            "description": "\(error.localizedDescription)"
        ])
    }
    
    public func error(_ message: Logger.Message, for error: any Error) {
        self.error(message, metadata: [
            "error": "\(error)",
            "description": "\(error.localizedDescription)"
        ])
    }
}
