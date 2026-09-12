import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject private var app: AppController
    @State private var email = ""
    @State private var password = ""
    @State private var role: UserRole = .student
    @State private var showPass = false
    @State private var loading = false
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            BrandMark()
                            VStack(alignment: .leading, spacing: 2) {
                                Text("LARPING UNIVERSITY").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white.opacity(0.5)).tracking(1.6)
                                Text("Campus Lost & Found").font(.system(size: 22, weight: .black)).foregroundStyle(.white)
                            }
                        }
                        Text("Reconnecting students with their belongings").font(.system(size: 14)).foregroundStyle(.white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .padding(.bottom, 32)
                    .crimsonHeader()

                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Sign in as").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.label3).textCase(.uppercase)
                            RolePicker(role: $role)
                        }
                        VStack(spacing: 0) {
                            TextField("", text: $email, prompt: Text(role == .student ? "alex@larping.edu" : "employee@larping.edu").foregroundStyle(AppColors.placeholder))
                                .textInputAutocapitalization(.never).keyboardType(.emailAddress).autocorrectionDisabled()
                                .foregroundStyle(AppColors.label).padding(16)
                            Divider().background(AppColors.sep)
                            HStack {
                                Group {
                                    if showPass { TextField("", text: $password, prompt: Text("Password").foregroundStyle(AppColors.placeholder)) }
                                    else { SecureField("", text: $password, prompt: Text("Password").foregroundStyle(AppColors.placeholder)) }
                                }
                                .foregroundStyle(AppColors.label)
                                Button(showPass ? "Hide" : "Show") { showPass.toggle() }
                                    .font(.system(size: 13, weight: .medium)).foregroundStyle(AppColors.label3)
                            }
                            .padding(16)
                        }
                        .background(AppColors.card)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.sep, lineWidth: 1.5))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                        HStack {
                            Spacer()
                            NavigationLink("Forgot Password?") { ForgotPasswordScreen() }
                                .font(.system(size: 14, weight: .medium)).foregroundStyle(AppColors.red)
                        }
                        AppButton(title: loading ? "Signing In…" : "Log In", enabled: !email.isEmpty && !password.isEmpty, loading: loading) {
                            loading = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                loading = false
                                _ = app.login(email: email, password: password, role: role)
                            }
                        }
                        HStack(spacing: 6) {
                            Spacer()
                            Text("Don't have an account?").foregroundStyle(AppColors.label3).font(.system(size: 15))
                            NavigationLink("Sign Up") { SignUpScreen() }
                                .font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.red)
                            Spacer()
                        }
                        Text("Demo: student@larping.edu or employee@larping.edu · 123456")
                            .font(.system(size: 12)).foregroundStyle(AppColors.label3)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(20)
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
