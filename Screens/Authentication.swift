import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject var app: AppController

    @State private var email = ""
    @State private var password = ""
    @State private var role: UserRole = .student
    @State private var showPassword = false
    @State private var showSignup = false
    @State private var showForgot = false
    @State private var showError = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    Spacer(minLength: 35)

                    AppLogo()

                    VStack(spacing: 5) {
                        Text("Campus Lost & Found")
                            .font(.title.bold())
                            .foregroundStyle(.white)

                        Text("Larping University")
                            .foregroundStyle(AppTheme.secondaryText)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("ACCOUNT TYPE")
                            .font(.caption.bold())
                            .tracking(1)
                            .foregroundStyle(AppTheme.secondaryText)

                        Picker("Role", selection: $role) {
                            ForEach(UserRole.allCases) { role in
                                Text(role.rawValue)
                                    .tag(role)
                            }
                        }
                        .pickerStyle(.segmented)

                        TextField("Email", text: $email)
                            .textFieldStyle(AppTextFieldStyle())
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)

                        HStack {
                            Group {
                                if showPassword {
                                    TextField("Password", text: $password)
                                } else {
                                    SecureField("Password", text: $password)
                                }
                            }

                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(
                                    systemName: showPassword
                                    ? "eye.slash"
                                    : "eye"
                                )
                                .foregroundStyle(AppTheme.secondaryText)
                            }
                        }
                        .padding()
                        .background(AppTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                        HStack {
                            Spacer()

                            Button("Forgot Password?") {
                                showForgot = true
                            }
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.crimson)
                        }

                        PrimaryButton(
                            title: "Log In",
                            icon: "arrow.right"
                        ) {
                            login()
                        }
                    }

                    VStack(spacing: 10) {
                        Text("QUICK TEST LOGIN")
                            .font(.caption.bold())
                            .tracking(1)
                            .foregroundStyle(AppTheme.secondaryText)

                        SecondaryButton(
                            title: "Student Demo",
                            icon: "person"
                        ) {
                            role = .student
                            email = "student@larping.edu"
                            password = "123456"
                            login()
                        }

                        SecondaryButton(
                            title: "Employee Demo",
                            icon: "person.badge.shield.checkmark"
                        ) {
                            role = .employee
                            email = "employee@larping.edu"
                            password = "123456"
                            login()
                        }
                    }

                    Button {
                        showSignup = true
                    } label: {
                        HStack {
                            Text("Don't have an account?")
                                .foregroundStyle(AppTheme.secondaryText)

                            Text("Sign Up")
                                .foregroundStyle(AppTheme.crimson)
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding(22)
            }
            .appBackground()
            .navigationDestination(isPresented: $showSignup) {
                SignUpScreen()
            }
            .navigationDestination(isPresented: $showForgot) {
                ForgotPasswordScreen()
            }
            .alert(
                "Login Error",
                isPresented: $showError
            ) {
                Button("OK") {}
            } message: {
                Text(app.errorMessage ?? "Unable to log in.")
            }
            .onChange(of: app.errorMessage) { _, value in
                showError = value != nil
            }
        }
    }

    private func login() {
        let success = app.login(
            email: email,
            password: password,
            role: role
        )

        if !success {
            showError = true
        }
    }
}

struct SignUpScreen: View {
    @EnvironmentObject var app: AppController
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var universityID = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var role: UserRole = .student
    @State private var showError = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScreenHeader(
                    title: "Create Account",
                    subtitle: "Join Larping University Lost & Found"
                )

                TextField("Full Name", text: $name)
                    .textFieldStyle(AppTextFieldStyle())

                TextField("University ID", text: $universityID)
                    .textFieldStyle(AppTextFieldStyle())

                TextField("Email", text: $email)
                    .textFieldStyle(AppTextFieldStyle())
                    .textInputAutocapitalization(.never)

                SecureField("Password", text: $password)
                    .textFieldStyle(AppTextFieldStyle())

                SecureField(
                    "Confirm Password",
                    text: $confirmPassword
                )
                .textFieldStyle(AppTextFieldStyle())

                Text("ACCOUNT TYPE")
                    .font(.caption.bold())
                    .tracking(1)
                    .foregroundStyle(AppTheme.secondaryText)

                Picker("Role", selection: $role) {
                    ForEach(UserRole.allCases) { role in
                        Text(role.rawValue)
                            .tag(role)
                    }
                }
                .pickerStyle(.segmented)

                PrimaryButton(
                    title: "Create Account",
                    icon: "person.badge.plus"
                ) {
                    createAccount()
                }
            }
            .padding(20)
        }
        .appBackground()
        .navigationTitle("")
        .alert(
            "Signup Error",
            isPresented: $showError
        ) {
            Button("OK") {}
        } message: {
            Text(app.errorMessage ?? "Please check your information.")
        }
    }

    private func createAccount() {
        let success = app.signup(
            fullName: name,
            universityID: universityID,
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            role: role
        )

        if !success {
            showError = true
        }
    }
}

struct ForgotPasswordScreen: View {
    @EnvironmentObject var app: AppController

    @State private var email = ""
    @State private var submitted = false

    var body: some View {
        VStack(spacing: 20) {
            ScreenHeader(
                title: "Forgot Password",
                subtitle: "Enter your email to reset your password."
            )

            TextField("Email", text: $email)
                .textFieldStyle(AppTextFieldStyle())
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)

            PrimaryButton(
                title: "Send Reset Request",
                icon: "envelope"
            ) {
                guard !email.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty else {
                    app.errorMessage = "Please enter your email."
                    return
                }

                submitted = true
            }

            Spacer()
        }
        .padding(20)
        .appBackground()
        .alert(
            "Request Sent",
            isPresented: $submitted
        ) {
            Button("Done") {}
        } message: {
            Text(
                "If an account exists for this email, reset instructions would be sent. This demo does not use a real email service."
            )
        }
    }
}

struct ScreenHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AppTextFieldStyle: TextFieldStyle {
    func _body(
        configuration: TextField<Self._Label>
    ) -> some View {
        configuration
            .foregroundStyle(.white)
            .padding()
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}