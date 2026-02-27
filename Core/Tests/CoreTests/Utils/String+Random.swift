import Foundation

extension String {
    static func random(
        includeUppercase: Bool = true,
        includeLowercase: Bool = true,
        includeSymbolsAndPunctuation: Bool = true,
        includeNumbers: Bool = true,
        lengthOfEach: Int = Int.random(in: 1...20)
    ) -> String {
        let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let lowercase = "abcdefghijklmnopqrstuvwxyz"
        let symbolsAndPunctuation = "!@#$%^&*()-_=+<>/?.,';\"[]{}\\|`~ "
        let numbers = "1234567890"
        
        
        var result = ""
        
        for _ in 0..<lengthOfEach {
            if includeUppercase { result.append(uppercase.randomElement()!) }
            if includeLowercase { result.append(lowercase.randomElement()!) }
            if includeSymbolsAndPunctuation { result.append(symbolsAndPunctuation.randomElement()!) }
            if includeNumbers { result.append(numbers.randomElement()!) }
        }
        
        return result
    }
}
