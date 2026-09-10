import SwiftUI

struct SignUpScreen: View {
    @EnvironmentObject private var app: AppController
    @State private var name = ""
    @State private var universityID = ""
    @State private var email = ""
    @State private var password = ""
    var body: some View {
        Form {
            TextField("Full name", text: $name)
            TextField("University ID", text: $universityID)
            TextField("Email", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never).autocorrectionDisabled()
            SecureField("Password (at least 6 characters)", text: $password)
            AppButton(title: "Create Student Account") {
                _ = app.signup(fullName: name, email: email, password: password, universityID: universityID)
            }
        }.appBackground().navigationTitle("Student Sign Up")
    }
}
