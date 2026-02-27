import Foundation

public extension Validator where Self == EmailValidator {
    static var isEmail: Self { EmailValidator() }
}

public struct EmailValidator: Validator {
    public func validate(_ validated: inout Validated<String>) {
        if validated.value.wholeMatch(of: /^[\w\-\.]+@([\w-]+\.)+[\w-]{2,}$/) == nil {
            validated.issues.append("Must be a valid email")
        }
    }
}
