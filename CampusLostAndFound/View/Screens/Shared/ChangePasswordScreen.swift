import SwiftUI

struct ChangePasswordScreen: View {
    @EnvironmentObject private var app: AppController
    @Environment(\.dismiss) private var dismiss
    @State private var current = ""
    @State private var newPw = ""
    @State private var confirm = ""
    @State private var showCur = false
    @State private var showNew = false
    @State private var showCon = false
    @State private var success = false
    var body: some View {
        ScrollView {
            if success {
                VStack(spacing: 20) {
                    Spacer()
                    Circle().fill(AppColors.greenLight).frame(width: 96, height: 96)
                        .overlay(Image(systemName: "checkmark").font(.system(size: 36, weight: .bold)).foregroundStyle(AppColors.green))
                    Text("Password Updated").font(.system(size: 26, weight: .black)).foregroundStyle(AppColors.label)
                    Text("Your password has been changed successfully.").foregroundStyle(AppColors.label3)
                    AppButton(title: "Done") { dismiss() }
                    Spacer()
                }.padding(32)
            } else {
                VStack(spacing: 16) {
                    LabeledField(label: "Current Password", placeholder: "Enter current password", text: $current, secure: true, showSecure: showCur, onToggle: { showCur.toggle() })
                    LabeledField(label: "New Password", placeholder: "Min 8 characters", text: $newPw, secure: true, showSecure: showNew, onToggle: { showNew.toggle() })
                    LabeledField(label: "Confirm New Password", placeholder: "Re-enter new password", text: $confirm, secure: true, showSecure: showCon, onToggle: { showCon.toggle() })
                    AppButton(title: "Update Password", enabled: !current.isEmpty && !newPw.isEmpty && !confirm.isEmpty) {
                        if app.changePassword(currentPassword: current, newPassword: newPw, confirmPassword: confirm) { success = true }
                    }
                }.padding(16)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Change Password")
    }
}
