import Foundation

public struct Validated<Value> {
    public var value: Value
    public var issues: [LocalizedStringResource]
    
    public init(_ value: Value) {
        self.value = value
        self.issues = []
    }
    
    @discardableResult
    public mutating func validate(_ validators: any Validator<Value>...) -> Bool {
        validate(validators)
    }
    
    @discardableResult
    public mutating func validate(_ validations: [any Validator<Value>]) -> Bool {
        self.issues = []
        for validation in validations {
            validation.validate(&self)
        }
        return self.issues.isEmpty
    }
}
