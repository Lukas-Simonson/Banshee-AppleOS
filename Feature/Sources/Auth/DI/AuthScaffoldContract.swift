import Core
import Logging

public protocol AuthScaffoldContract {
    func logger() -> Logger
    
    func navigator() -> AuthNavigationContract
    
    func repository() -> AuthRepositoryContract
}
