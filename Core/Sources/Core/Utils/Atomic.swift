import Foundation

@propertyWrapper
public struct Atomic<T> {
    private var storage: T
    private var lock: NSRecursiveLock
    
    public var wrappedValue: T {
        get { lock.withLock { storage } }
        set { lock.withLock { storage = newValue } }
    }
    
    public var projectedValue: Atomic<T> {
        get { self }
        set { self = newValue }
    }
    
    public init(wrappedValue: T, lock: NSRecursiveLock = .init()) {
        self.storage = wrappedValue
        self.lock = lock
    }
    
    public mutating func execute(_ action: (inout T) -> Void) {
        lock.withLock {
            action(&storage)
        }
    }
}

extension Atomic: Sendable where T: Sendable { }
