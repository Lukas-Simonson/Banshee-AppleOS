import Foundation

public extension Validator where Self == MinSizeValidator<String> {
    static func hasMinSize(of size: Int) -> Self {
        MinSizeValidator(
            size: size,
            message: "Must be at least \(size) characters long."
        )
    }
}

public struct MinSizeValidator<Value: Collection>: Validator {
    
    let size: Int
    let message: LocalizedStringResource
    
    public func validate(_ validated: inout Validated<Value>) {
        if validated.value.count < size {
            validated.issues.append(message)
        }
    }
}
