import SwiftUI

struct SignUpScreen: View {
    @EnvironmentObject private var app: AppController
    @Environment(\.dismiss) private var dismiss
    @State private var role: UserRole = .student
    @State private var name = ""
    @State private var uid = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirm = ""
    @State private var showPass = false
    @State private var showConfirm = false
    @State private var done = false
    @State private var loading = false
    private var emailOK: Bool { email.contains("@") && email.contains(".") }
    private var passOK: Bool { password.count >= 8 && password.rangeOfCharacter(from: .uppercaseLetters) != nil && password.rangeOfCharacter(from: .decimalDigits) != nil }
    private var formOK: Bool { name.trimmingCharacters(in: .whitespaces).count > 1 && uid.count > 2 && emailOK && passOK && password == confirm }
    var body: some View {
        ScrollView {
            if done {
                success
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        Button { dismiss() } label: {
                            HStack(spacing: 4) { Image(systemName: "chevron.left").font(.system(size: 17, weight: .semibold)); Text("Log In") }
                                .foregroundStyle(.white)
                        }
                        Text("Create an\nAccount").font(.system(size: 28, weight: .black)).foregroundStyle(.white)
                        Text("Join the Campus Lost & Found community").font(.system(size: 14)).foregroundStyle(.white.opacity(0.45))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20).padding(.top, 12).padding(.bottom, 28)
                    .crimsonHeader()

                    VStack(alignment: .leading, spacing: 16) {
                        Text("I am a:").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.label3).textCase(.uppercase)
                        RolePicker(role: $role)
                        LabeledField(label: "Full Name", placeholder: "e.g. Alex Jordan", text: $name)
                        LabeledField(label: role == .student ? "Student ID" : "Employee ID", placeholder: role == .student ? "e.g. 2024-0042" : "e.g. EMP-0042", text: $uid)
                        LabeledField(label: "University Email", placeholder: "you@larping.edu", text: $email)
                        LabeledField(label: "Password", placeholder: "Min 8 chars, 1 uppercase, 1 number", text: $password, secure: true, showSecure: showPass, onToggle: { showPass.toggle() })
                        if !password.isEmpty {
                            HStack(spacing: 4) {
                                let checks = [password.count >= 8, password.rangeOfCharacter(from: .uppercaseLetters) != nil, password.rangeOfCharacter(from: .decimalDigits) != nil, password.count >= 12]
                                ForEach(0..<4, id: \.self) { i in
                                    Capsule().fill(checks[i] ? AppColors.green : AppColors.fill).frame(height: 4)
                                }
                            }
                            Text(passHint).font(.system(size: 12, weight: .medium)).foregroundStyle(passOK ? AppColors.green : AppColors.orange)
                        }
                        LabeledField(label: "Confirm Password", placeholder: "Re-enter your password", text: $confirm, error: !confirm.isEmpty && confirm != password ? "Passwords do not match." : nil, secure: true, showSecure: showConfirm, onToggle: { showConfirm.toggle() })
                        AppButton(title: loading ? "Creating Account…" : "Create Account", enabled: formOK, loading: loading) {
                            loading = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                loading = false
                                if app.signup(fullName: name, email: email, password: password, universityID: uid, confirmPassword: confirm, role: role) {
                                    done = true
                                }
                            }
                        }
                        HStack {
                            Spacer()
                            Text("Already have an account?").foregroundStyle(AppColors.label3)
                            Button("Log In") { dismiss() }.foregroundStyle(AppColors.red).fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .padding(20)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var passHint: String {
        if password.count < 8 { return "Too short" }
        if password.rangeOfCharacter(from: .uppercaseLetters) == nil { return "Add an uppercase letter" }
        if password.rangeOfCharacter(from: .decimalDigits) == nil { return "Add a number" }
        if password.count < 12 { return "Good password" }
        return "Strong password ✓"
    }

    private var success: some View {
        VStack(spacing: 24) {
            Spacer()
            Circle().fill(AppColors.greenLight).frame(width: 96, height: 96).overlay(Image(systemName: "checkmark").font(.system(size: 36, weight: .bold)).foregroundStyle(AppColors.green))
            Text("Account Created!").font(.system(size: 26, weight: .black)).foregroundStyle(AppColors.label)
            Text("Your account is ready. You are signed in to Campus Lost & Found.").font(.system(size: 15)).foregroundStyle(AppColors.label3).multilineTextAlignment(.center)
            AppButton(title: "Continue") { _ = app.login(email: email, password: password, role: role) }
            Spacer()
        }
        .padding(32)
    }
}
