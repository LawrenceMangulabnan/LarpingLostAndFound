import SwiftUI

struct ChangePasswordScreen: View {
    @EnvironmentObject private var app: AppController
    @Environment(\.dismiss) private var dismiss
    @State private var current = ""
    @State private var new = ""
    @State private var confirm = ""
    var body: some View {
        Form {
            SecureField("Current Password", text: $current)
            SecureField("New Password", text: $new)
            SecureField("Confirm New Password", text: $confirm)
            AppButton(title: "Change Password") {
                if app.changePassword(currentPassword: current, newPassword: new, confirmPassword: confirm) { dismiss() }
            }
        }.appBackground().navigationTitle("Change Password")
    }
}
