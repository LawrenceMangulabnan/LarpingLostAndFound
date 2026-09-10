import SwiftUI

struct ForgotPasswordScreen: View {
    @EnvironmentObject private var app: AppController
    @State private var email = ""
    var body: some View {
        Form {
            Text("Simulate password reset instructions for this local prototype.")
            TextField("Email", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never)
            AppButton(title: "Send Reset Instructions") { app.resetPassword(email: email) }
        }.appBackground().navigationTitle("Forgot Password")
    }
}
