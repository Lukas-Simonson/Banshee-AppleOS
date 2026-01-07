import Logging
import os

typealias OSLog = os.Logger
typealias Log = Logging.Logger

struct OSLogHandler: LogHandler {
    var metadata = Log.Metadata()
    var logLevel: Log.Level = .info
    private let logger: OSLog
    
    public init(label: String) {
        logger = OSLog(subsystem: label, category: "")
    }
    
    func log(level: Log.Level, message: Log.Message, metadata override: Log.Metadata?, source: String, file: String, function: String, line: UInt) {
        let prettyMetadata = (override ?? self.metadata).pretty()
        let metadataString = prettyMetadata == nil ? "" : "\n\t[METADATA]:\(prettyMetadata!)"

        let finalMessage = "[\(source)] \(message.description) \(metadataString)"
        
        switch level {
            case .trace: logger.trace("🔍 \(finalMessage, privacy: .public)")
            case .debug: logger.debug("🐞 \(finalMessage, privacy: .public)")
            case .info: logger.info("ℹ️ \(finalMessage, privacy: .public)")
            case .notice: logger.notice("📌 \(finalMessage, privacy: .public)")
            case .warning: logger.warning("⚠️ \(finalMessage, privacy: .public)")
            case .error: logger.error("❌ \(finalMessage, privacy: .public)")
            case .critical: logger.critical("🔥 \(finalMessage, privacy: .public)")
        }
    }
}

extension OSLogHandler {
    subscript(metadataKey key: String) -> Log.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }
}

extension Log.Metadata {
    func pretty() -> String? {
        isEmpty ? nil : reduce("") { $0 + "\n\t - \($1.key): \($1.value)" }
    }
}
