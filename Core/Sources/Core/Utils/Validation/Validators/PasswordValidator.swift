import Foundation

public extension Validator where Self == PasswordValidator {
    static var isPassword: Self { PasswordValidator() }
}

public struct PasswordValidator: Validator {
    public func validate(_ validated: inout Validated<String>) {
        var containsUppercase = false
        var containsLowercase = false
        var containsNumber = false
        var containsSpecial = false
        
        for char in validated.value {
            if char.isLowercase { containsLowercase = true }
            else if char.isUppercase { containsUppercase = true }
            else if char.isNumber { containsNumber = true }
            else if char.isSymbol || char.isPunctuation { containsSpecial = true }
            
            if containsUppercase && containsLowercase && containsSpecial && containsNumber {
                break
            }
        }
        
        if !containsLowercase { validated.issues.append("Must contain one lowercase letter") }
        if !containsUppercase { validated.issues.append("Must contain one uppercase letter") }
        if !containsNumber { validated.issues.append("Must contain one number") }
        if !containsSpecial { validated.issues.append("Must contain one special character") }
        if validated.value.count < 8 { validated.issues.append("Must be at least 8 characters long") }
    }
}
