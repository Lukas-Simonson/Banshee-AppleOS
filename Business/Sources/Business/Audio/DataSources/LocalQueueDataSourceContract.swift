import Core

public protocol LocalQueueDataSourceContract: Sendable {
    func get() -> AudioQueue?
    func save(_ queue: AudioQueue)
    func clear()
}
