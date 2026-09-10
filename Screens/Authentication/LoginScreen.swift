import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject private var app: AppController
    @State private var email = ""
    @State private var password = ""
    @State private var role: UserRole = .student
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Campus Lost & Found").font(.largeTitle.bold())
                    Text("Larping University").foregroundStyle(AppColors.secondaryText)
                }
                Section("Sign in") {
                    TextField("Email", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never).autocorrectionDisabled()
                    SecureField("Password", text: $password)
                    Picker("Role", selection: $role) {
                        ForEach(UserRole.allCases) { Text($0.rawValue).tag($0) }
                    }.pickerStyle(.segmented)
                    AppButton(title: "Login") { _ = app.login(email: email, password: password, role: role) }
                    NavigationLink("Forgot Password") { ForgotPasswordScreen() }
                    NavigationLink("Create Student Account") { SignUpScreen() }
                }
                Section("Demo accounts") {
                    Text("Student: student@larping.edu\nEmployee: employee@larping.edu\nPassword: 123456")
                    Text("Testing only: a new email creates a local mock account. Existing accounts require the correct password and role.").font(.caption)
                }
            }.appBackground()
        }
    }
}
