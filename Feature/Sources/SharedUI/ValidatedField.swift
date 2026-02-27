import Brute
import Core
import SwiftUI

public struct ValidatedField<Value, Field: View>: View {

    @Environment(\.bruteContext) private var context

    @Binding var validatable: Validated<Value>

    let field: (Binding<Value>) -> Field

    public init(
        _ validatable: Binding<Validated<Value>>,
        @ViewBuilder field: @escaping (Binding<Value>) -> Field
    ) {
        self._validatable = validatable
        self.field = field
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: context.dimen.paddingSmall) {
            field($validatable.value)

            if !validatable.issues.isEmpty {
                VStack(alignment: .leading, spacing: context.dimen.paddingSmall)
                {
                    ForEach(validatable.issues, id: \.key) { issue in
                        Text(verbatim: "× ") + Text(issue)
                    }
                }
                .transition(.scale)
                .foregroundStyle(Color.red)
                .padding(.leading, context.dimen.paddingSmall)
            }
        }
        .animation(.default, value: validatable.issues)
    }
}

#Preview {

    @Previewable @State var valid = Validated("Hello, World")

    BruteStyle {
        BruteSection("Validate Me") {
            VStack {
                ValidatedField($valid) { value in
                    TextField("Password", text: value)
                        .textFieldStyle(.brute)
                }

                Button("Validate") {
                    valid.validate(
                        .isAlphanumeric,
//                        .isEmail,
                    )
                }
            }
        }
        .padding()
    }
}
