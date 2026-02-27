import Foundation

public protocol Validator<Value> {
    associatedtype Value

    func validate(_ validated: inout Validated<Value>)
}
