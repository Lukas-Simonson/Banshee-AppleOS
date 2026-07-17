import Core
import Foundation
import SwiftUI

extension String {
    public var htmlStripped: String {
        replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
}

extension Binding<String?> {
    public func nilEmptyBinding() -> Binding<String> {
        Binding<String>(
            get: { wrappedValue ?? "" },
            set: { wrappedValue = $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : $0 }
        )
    }
}

extension Binding<ConfigValue<String>> {
    public func valueOrEmptyBinding() -> Binding<String> {
        Binding<String>(
            get: {
                if case .replace(let value) = self.wrappedValue {
                    return value
                }
                return ""
            },
            set: { newValue in
                self.wrappedValue = .replace(newValue)
            }
        )
    }
}
