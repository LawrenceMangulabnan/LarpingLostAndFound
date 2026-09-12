import SwiftUI

struct ForgotPasswordScreen: View {
    @EnvironmentObject private var app: AppController
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var sent = false
    @State private var loading = false
    var body: some View {
        ScrollView {
            if sent {
                VStack(spacing: 24) {
                    Spacer()
                    Circle().fill(AppColors.blueLight).frame(width: 96, height: 96).overlay(Text("📬").font(.system(size: 44)))
                    Text("Check Your Email").font(.system(size: 26, weight: .black)).foregroundStyle(AppColors.label)
                    Text("We sent a password reset link to \(email)").font(.system(size: 15)).foregroundStyle(AppColors.label3).multilineTextAlignment(.center)
                    Text("This local prototype does not send real email.").font(.system(size: 13)).foregroundStyle(AppColors.label3)
                    AppButton(title: "Back to Login") { dismiss() }
                    Spacer()
                }
                .padding(32)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        Button { dismiss() } label: {
                            HStack(spacing: 4) { Image(systemName: "chevron.left"); Text("Log In") }.foregroundStyle(.white)
                        }
                        Text("Forgot\nPassword?").font(.system(size: 28, weight: .black)).foregroundStyle(.white)
                        Text("Enter your email and we will send a reset link").font(.system(size: 14)).foregroundStyle(.white.opacity(0.45))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24).padding(.bottom, 32)
                    .crimsonHeader()
                    VStack(spacing: 20) {
                        LabeledField(label: "University Email", placeholder: "you@larping.edu", text: $email)
                        AppButton(title: loading ? "Sending…" : "Send Reset Link", enabled: !email.isEmpty, loading: loading) {
                            loading = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                loading = false
                                if app.resetPassword(email: email) { sent = true }
                            }
                        }
                        HStack {
                            Spacer()
                            Text("Remember your password?").foregroundStyle(AppColors.label3)
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
}
