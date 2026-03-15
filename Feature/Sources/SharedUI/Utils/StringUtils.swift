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
