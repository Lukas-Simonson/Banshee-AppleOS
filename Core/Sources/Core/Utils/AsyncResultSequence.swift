import Foundation

public typealias AsyncResultSequence<T: Sendable, E: Error> = AsyncSequence<Result<T, E>, Never>
