//
//  StringBinding+NilIfEmpty.swift
//  Feature
//
//  Created by Lukas Simonson on 2/25/26.
//

import SwiftUI

extension Binding<String?> {
    func nilEmptyBinding() -> Binding<String> {
        Binding<String>(
            get: { wrappedValue ?? "" },
            set: { wrappedValue = $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : $0 }
        )
    }
}
