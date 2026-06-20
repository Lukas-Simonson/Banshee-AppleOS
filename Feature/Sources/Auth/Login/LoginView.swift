import SwiftUI
import Brute

struct LoginView: View {
    @Environment(\.bruteContext) private var context
    
    let isLoading: Bool
    let loginEnabled: Bool
    
    @Binding var serverURL: String
    @Binding var username: String
    @Binding var password: String
    
    let onLogin: () -> Void
    let onSetupServer: () -> Void
    
    var body: some View {
        BruteStyle {
            BruteCard {
                HStack {
                    Text("Banshee")
                        .font(context.font.title)
                    Spacer()
                    Button("Server Setup", action: onSetupServer)
                }
                
                TextField("Server URL", text: $serverURL)
                    .keyboardType(.URL)
                    .textContentType(.URL)
                
                TextField("Email / Username", text: $username)
                    .textContentType(.username)
                
                SecureField("Password", text: $password)
                
                Button(action: onLogin) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                        
                        Text("Login")
                    }
                    .frame(maxWidth: .infinity)
                }
                .disabled(!loginEnabled)
            }
            .animation(.default, value: isLoading)
            .textFieldStyle(.brute)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .padding()
            .disabled(isLoading)
        }
    }
}

#Preview {
    @Previewable @State var url = ""
    @Previewable @State var user = ""
    @Previewable @State var pass = ""
    @Previewable @State var isLoading = false
    
    LoginView(
        isLoading: isLoading,
        loginEnabled: true,
        serverURL: $url,
        username: $user,
        password: $pass,
        onLogin: {
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        },
        onSetupServer: {
            
        }
    )
}
