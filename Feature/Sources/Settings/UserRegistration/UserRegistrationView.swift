import Brute
import Core
import SharedUI
import SwiftUI

struct UserRegistrationView: View {
    
    @Environment(\.bruteContext) private var context
    
    let role: User.Role
    
    @Binding var name: Validated<String>
    @Binding var username: Validated<String>
    @Binding var email: Validated<String>
    @Binding var password: Validated<String>
    
    let onNavigateBack: () -> Void
    let onCreateUser: () -> Void
    
    @FocusState var selection: Field?
    
    public var body: some View {
        BruteStyle {
            VStack(spacing: 0) {
                TopAppBar(
                    title: "Create \(role.rawValue.capitalized)",
                    leading: { NavigateBackButton(onNavigateBack) }
                )
                
                ScrollView {
                    VStack(spacing: context.dimen.paddingMedium) {
                        nameSection
                        emailSection
                        usernameSection
                        passwordSection
                        saveButton
                    }
                    .padding(context.dimen.paddingMedium)
                    .textFieldStyle(.brute)
                }
                .onSubmit { selection = selection?.next }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private var nameSection: some View {
        BruteSection("Name") {
            ValidatedField($name) { name in
                TextField("Name", text: name, prompt: Text(verbatim: "Bastilla Gravewynd"))
                    .focused($selection, equals: .name)
            }
        }
    }
    
    private var emailSection: some View {
        BruteSection("Email") {
            ValidatedField($email) { email in
                TextField("Email", text: email, prompt: Text(verbatim: "bastilla@example.com"))
                    .focused($selection, equals: .email)
            }
        }
    }
    
    private var usernameSection: some View {
        BruteSection("Username") {
            ValidatedField($username) { username in
                TextField("Username", text: username, prompt: Text(verbatim: "Bastilla123"))
                    .focused($selection, equals: .username)
            }
        }
    }
    
    private var passwordSection: some View {
        BruteSection("Password") {
            ValidatedField($password) { password in
                SecureField("Password", text: password, prompt: Text(verbatim: "1-Secure-Password"))
                    .focused($selection, equals: .password)
            }
        }
    }
    
    private var saveButton: some View {
        Button(action: onCreateUser) {
            Text("Create \(role.rawValue.capitalized)")
                .frame(maxWidth: .infinity)
        }
    }
    
    enum Field {
        case name
        case email
        case username
        case password
        
        var next: Field? {
            switch self {
                case .name: .email
                case .email: .username
                case .username: .password
                case .password: nil
            }
        }
    }
}

#Preview {
    @Previewable @State var name = Validated("")
    @Previewable @State var username = Validated("")
    @Previewable @State var email = Validated("")
    @Previewable @State var password = Validated("")
    
    UserRegistrationView(
        role: .admin,
        name: $name,
        username: $username,
        email: $email,
        password: $password,
        onNavigateBack: { },
        onCreateUser: {
            name.validate(
                .trimmingCharacters(in: .whitespacesAndNewlines),
                .hasMinSize(of: 2)
            )
            username.validate(.isAlphanumeric)
            email.validate(.isEmail)
            password.validate(.isPassword)
        }
    )
}
