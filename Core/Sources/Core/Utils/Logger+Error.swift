import Logging

extension Logger {
    public func error(_ message: Logger.Message, for error: any Error) {
        self.error(message, metadata: [
            "error": "\(error)",
            "description": "\(error.localizedDescription)"
        ])
    }
}
