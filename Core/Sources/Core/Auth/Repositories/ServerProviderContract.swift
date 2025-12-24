
public protocol ServerProviderContract: Sendable {
    var server: String? { get async }
    var token: AuthToken? { get async }
}
