import Foundation

public final class Debounce<each Parameter: Sendable>: @unchecked Sendable {
    private let action: @Sendable (repeat each Parameter) async -> Void
    private let delay: Duration
    private let lock = NSLock()
    private var task: Task<Void, Never>?
    
    public init(
        _ action: @Sendable @escaping (repeat each Parameter) async -> Void,
        for delay: Duration
    ) {
        self.action = action
        self.delay = delay
    }
    
    public func callAsFunction(_ parameter: repeat each Parameter) {
        lock.withLock {
            task?.cancel()
            task = Task { [delay, weak self] in
                try? await Task.sleep(for: delay)
                guard !Task.isCancelled, let self else { return }
                await self.action(repeat each parameter)
            }
        }
    }
    
    public func cancel() {
        lock.withLock {
            task?.cancel()
            task = nil
        }
    }
}
