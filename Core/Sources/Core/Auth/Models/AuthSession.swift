import Foundation

public struct AuthSession: Equatable, Sendable {
    public let user: User
    public let token: AuthToken
    public let loginDate: Date
    
    public init(user: User, token: AuthToken, loginDate: Date = .now) {
        self.user = user
        self.token = token
        self.loginDate = loginDate
    }
}
