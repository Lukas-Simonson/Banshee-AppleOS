import Brute
import Core
import SharedUI
import SwiftUI

struct ServerSetupView: View {

    @Environment(\.bruteContext) private var context

    let isLoading: Bool

    @Binding var baseURL: Validated<String>
    @Binding var name: Validated<String>
    @Binding var username: Validated<String>
    @Binding var email: Validated<String>
    @Binding var password: Validated<String>

    let onNavigateBack: () -> Void
    let onCompleteSetup: () -> Void

    @FocusState var selection: Field?

    public var body: some View {
        BruteStyle {
            VStack(spacing: 0) {
                TopAppBar(
                    title: "Setup Server",
                    leading: { NavigateBackButton(onNavigateBack) }
                )

                ScrollView {
                    VStack(spacing: context.dimen.paddingMedium) {
                        baseURLSection
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
                .disabled(isLoading)
            }
        }
        .navigationBarBackButtonHidden()
    }

    private var baseURLSection: some View {
        BruteSection("Server URL") {
            ValidatedField($baseURL) { baseURL in
                TextField("Server URL", text: baseURL, prompt: Text(verbatim: "getbanshee.app"))
                    .keyboardType(.URL)
                    .textContentType(.URL)
                    .textInputAutocapitalization(.never)
                    .focused($selection, equals: .url)
            }
        }
    }

    private var nameSection: some View {
        BruteSection("Name") {
            ValidatedField($name) { name in
                TextField("Name", text: name, prompt: Text(verbatim: "Bastilla Gravewynd"))
                    .keyboardType(.default)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                    .focused($selection, equals: .name)
            }
        }
    }

    private var emailSection: some View {
        BruteSection("Email") {
            ValidatedField($email) { email in
                TextField("Email", text: email, prompt: Text(verbatim: "bastilla@example.com"))
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .focused($selection, equals: .email)
            }
        }
    }

    private var usernameSection: some View {
        BruteSection("Username") {
            ValidatedField($username) { username in
                TextField("Username", text: username, prompt: Text(verbatim: "Bastilla123"))
                    .keyboardType(.default)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .focused($selection, equals: .username)
            }
        }
    }

    private var passwordSection: some View {
        BruteSection("Password") {
            ValidatedField($password) { password in
                SecureField("Password", text: password, prompt: Text(verbatim: "1-Secure-Password"))
                    .keyboardType(.default)
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                    .focused($selection, equals: .password)
            }
        }
    }

    private var saveButton: some View {
        Button(action: onCompleteSetup) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                Text("Complete Setup")
            }
            .frame(maxWidth: .infinity)
        }
    }

    enum Field {
        case url
        case name
        case email
        case username
        case password

        var next: Field? {
            switch self {
                case .url: .name
                case .name: .email
                case .email: .username
                case .username: .password
                case .password: nil
            }
        }
    }
}

//struct ServerSetupView: View {
//    
//    @Environment(\.bruteContext) private var context
//    
//    let isLoading: Bool
//    
//    @Binding var baseURL: Validated<String>
//    @Binding var name: Validated<String>
//    @Binding var username: Validated<String>
//    @Binding var email: Validated<String>
//    @Binding var password: Validated<String>
//    
//    let onNavigateBack: () -> Void
//    let onCompleteSetup: () -> Void
//    
//    @FocusState var selection: Field?
//    
//    public var body: some View {
//        BruteStyle {
//            VStack(spacing: 0) {
//                TopAppBar(
//                    title: "Setup Server",
//                    leading: { NavigateBackButton(onNavigateBack) }
//                )
//                
//                ScrollView {
//                    BruteCard {
//                        VStack(alignment: .leading, spacing: context.dimen.paddingMedium) {
//                            Text("Server URL")
//                                .font(.title3.bold())
//                            baseURLSection
//                            
//                            Text("Name")
//                                .font(.title3.bold())
//                            nameSection
//                            
//                            Text("Email")
//                                .font(.title3.bold())
//                            emailSection
//                            
//                            Text("Username")
//                                .font(.title3.bold())
//                            usernameSection
//                            
//                            Text("Password")
//                                .font(.title3.bold())
//                            passwordSection
//                            
//
//                            saveButton
//                        }
//                    }
//                    .padding(context.dimen.paddingMedium)
//                    .textFieldStyle(.brute)
//                }
//                .onSubmit { selection = selection?.next }
//                .disabled(isLoading)
//            }
//        }
//        .navigationBarBackButtonHidden()
//    }
//    
//    private var baseURLSection: some View {
//        ValidatedField($baseURL) { baseURL in
//            TextField("Server URL", text: baseURL, prompt: Text(verbatim: "getbanshee.app"))
//                .keyboardType(.URL)
//                .textContentType(.URL)
//                .textInputAutocapitalization(.never)
//                .focused($selection, equals: .url)
//        }
//    }
//    
//    private var nameSection: some View {
//        ValidatedField($name) { name in
//            TextField("Name", text: name, prompt: Text(verbatim: "Bastilla Gravewynd"))
//                .keyboardType(.default)
//                .textContentType(.name)
//                .textInputAutocapitalization(.words)
//                .focused($selection, equals: .name)
//        }
//    }
//    
//    private var emailSection: some View {
//        ValidatedField($email) { email in
//            TextField("Email", text: email, prompt: Text(verbatim: "bastilla@example.com"))
//                .keyboardType(.emailAddress)
//                .textContentType(.emailAddress)
//                .textInputAutocapitalization(.never)
//                .focused($selection, equals: .email)
//        }
//    }
//    
//    private var usernameSection: some View {
//        ValidatedField($username) { username in
//            TextField("Username", text: username, prompt: Text(verbatim: "Bastilla123"))
//                .keyboardType(.default)
//                .textContentType(.username)
//                .textInputAutocapitalization(.never)
//                .focused($selection, equals: .username)
//        }
//    }
//    
//    private var passwordSection: some View {
//        ValidatedField($password) { password in
//            SecureField("Password", text: password, prompt: Text(verbatim: "1-Secure-Password"))
//                .keyboardType(.default)
//                .textContentType(.password)
//                .textInputAutocapitalization(.never)
//                .focused($selection, equals: .password)
//        }
//    }
//    
//    private var saveButton: some View {
//        Button(action: onCompleteSetup) {
//            HStack {
//                if isLoading {
//                    ProgressView()
//                        .progressViewStyle(.circular)
//                }
//                Text("Complete Setup")
//            }
//            .frame(maxWidth: .infinity)
//        }
//    }
//    
//    enum Field {
//        case url
//        case name
//        case email
//        case username
//        case password
//        
//        var next: Field? {
//            switch self {
//                case .url: .name
//                case .name: .email
//                case .email: .username
//                case .username: .password
//                case .password: nil
//            }
//        }
//    }
//}

#Preview {
    @Previewable @State var baseURL = Validated("")
    @Previewable @State var name = Validated("")
    @Previewable @State var username = Validated("")
    @Previewable @State var email = Validated("")
    @Previewable @State var password = Validated("")
    
    ServerSetupView(
        isLoading: false,
        baseURL: $baseURL,
        name: $name,
        username: $username,
        email: $email,
        password: $password,
        onNavigateBack: { },
        onCompleteSetup: {
            baseURL.validate(
                .hasMinSize(of: 2)
            )
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
