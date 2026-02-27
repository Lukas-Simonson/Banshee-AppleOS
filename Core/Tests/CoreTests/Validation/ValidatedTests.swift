import Foundation
@testable import Core
import Testing

@Suite
struct `Validated Tests` {
    @Test
    func `validate runs all tests in order`() {
        var validated = Validated(UUID())
        
        var count = 0
        
        validated.validate(
            ClosureValidator { _ in
                count += 1
                #expect(count == 1)
            },
            ClosureValidator { _ in
                count += 1
                #expect(count == 2)
            },
            ClosureValidator { _ in
                count += 1
                #expect(count == 3)
            }
        )
    }
    
    @Test
    func `validate sets correct number of issues`() {
        var validated = Validated(UUID())
        
        validated.issues.append("Failure") // adds an issue that should be cleared before validation.
        
        let random = Int.random(in: 1...5) // Test between 1 & 5 validations
        validated.validate((0..<random).map { _ in FailureValidator() })
        
        #expect(validated.issues.count == random, "Validate did not set expected values")
    }
    
    @Test
    func `validate returns is valid when no issues occur`() {
        var validated = Validated(UUID())
        
        let result = validated.validate(ClosureValidator(closure: { _ in }))
        
        #expect(result, "Validate responded with invalid when no issues occurred")
    }
    
    @Test
    func `validate returns not valid when issues occur`() {
        var validated = Validated(UUID())
        
        let result = validated.validate(FailureValidator())
        
        #expect(!result, "Validate responded as valid when issues occurred")
    }
}

@Suite
struct `Alphanumeric Validator Tests` {
    @Test
    func `invalidates values`() {
        var validated = Validated(String.random())
        
        let result = validated.validate(.isAlphanumeric)
        #expect(!result, "did not invalidate")
    }
    
    @Test
    func `validates values`() {
        var validated = Validated(String.random(includeSymbolsAndPunctuation: false, includeNumbers: false))
        
        let result = validated.validate(.isAlphanumeric)
        #expect(result, "invalidated")
    }
}

@Suite
struct `Email Validator Tests` {
    @Test
    func `invalidates values`() {
        var validated = Validated(String.random())
        
        let result = validated.validate(.isEmail)
        #expect(!result, "did not invalidate")
    }
    
    @Test
    func `validates values`() {
        var validated = Validated("bastilla@example.com")
        
        let result = validated.validate(.isEmail)
        #expect(result, "invalidated")
    }
}

@Suite
struct `Password Validator Tests` {
    @Test
    func `invalidates values`() {
        var validated = Validated(String.random(includeNumbers: false))
        
        let result = validated.validate(.isPassword)
        #expect(!result, "did not invalidate")
    }
    
    @Test
    func `validates values`() {
        var validated = Validated(String.random(lengthOfEach: 8))
        
        let result = validated.validate(.isPassword)
        #expect(result, "invalidated")
    }
}

private struct ClosureValidator<Value>: Validator {
    let closure: (inout Validated<Value>) -> Void
    
    func validate(_ validated: inout Validated<Value>) {
        closure(&validated)
    }
}

private struct FailureValidator<Value>: Validator {
    func validate(_ validated: inout Validated<Value>) {
        validated.issues.append("Failure")
    }
}
