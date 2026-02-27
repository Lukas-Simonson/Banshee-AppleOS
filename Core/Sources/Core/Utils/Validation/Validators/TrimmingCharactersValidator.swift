import Foundation

public extension Validator where Self == TrimmingCharactersValidator {
    static func trimmingCharacters(in set: CharacterSet) -> Self {
        TrimmingCharactersValidator(set: set)
    }
}

public struct TrimmingCharactersValidator: Validator {
    let set: CharacterSet
    
    public func validate(_ validated: inout Validated<String>) {
        validated.value = validated.value.trimmingCharacters(in: set)
    }
}
