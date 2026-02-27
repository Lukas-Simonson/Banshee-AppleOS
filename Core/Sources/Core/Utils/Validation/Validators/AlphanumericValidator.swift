import Foundation

public extension Validator where Self == AlphanumericValidator {
    static var isAlphanumeric: Self { AlphanumericValidator() }
}

public struct AlphanumericValidator: Validator {
    public func validate(_ validated: inout Validated<String>) {
        if validated.value.wholeMatch(of: /^[A-Za-z0-9]+$/) == nil {
            validated.issues.append("Must be alphanumeric")
        }
    }
}
