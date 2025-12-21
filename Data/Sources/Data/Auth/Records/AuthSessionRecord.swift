import Core
import Foundation

struct AuthSessionRecord: Codable {
    let user: UserRecord
    let loginDate: Date
    let tokenCreation: Date
}

extension AuthSessionRecord {
    init(from session: AuthSession) {
        self.user = UserRecord(from: session.user)
        self.loginDate = session.loginDate
        self.tokenCreation = session.token.createdAt
    }
    
    func toCore(with token: String) -> AuthSession {
        AuthSession(
            user: user.toCore(),
            token: AuthToken(token: token, createdAt: tokenCreation),
            loginDate: loginDate
        )
    }
}
