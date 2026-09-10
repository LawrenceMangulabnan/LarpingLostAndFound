import SwiftUI

struct EditProfileScreen: View {
    @EnvironmentObject var app: AppController
    @Environment(\.dismiss) private var dismiss

    @State private var fullName = ""
    @State private var universityID = ""
    @State private var saved = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScreenHeader(
                    title: "Edit Profile",
                    subtitle: "Update your account information."
                )

                TextField("Full Name", text: $fullName)
                    .textFieldStyle(AppTextFieldStyle())

                TextField(
                    "University ID",
                    text: $universityID
                )
                .textFieldStyle(AppTextFieldStyle())

                TextField(
                    "Email",
                    text: .constant(
                        app.currentUser?.email ?? ""
                    )
                )
                .textFieldStyle(AppTextFieldStyle())
                .disabled(true)
                .opacity(0.65)

                PrimaryButton(
                    title: "Save Profile",
                    icon: "checkmark"
                ) {
                    app.updateProfile(
                        fullName: fullName,
                        universityID: universityID
                    )
                    saved = true
                }
            }
            .padding(20)
        }
        .appBackground()
        .onAppear {
            fullName = app.currentUser?.fullName ?? ""
            universityID = app.currentUser?.universityID ?? ""
        }
        .alert("Profile Updated", isPresented: $saved) {
            Button("Done") {
                dismiss()
            }
        } message: {
            Text("Your profile information has been saved.")
        }
    }
}

struct ChangePasswordScreen: View {
    @EnvironmentObject var app: AppController
    @Environment(\.dismiss) private var dismiss

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showSuccess = false
    @State private var showError = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScreenHeader(
                    title: "Change Password",
                    subtitle: "Keep your account secure."
                )

                SecureField(
                    "Current Password",
                    text: $currentPassword
                )
                .textFieldStyle(AppTextFieldStyle())

                SecureField(
                    "New Password",
                    text: $newPassword
                )
                .textFieldStyle(AppTextFieldStyle())

                SecureField(
                    "Confirm New Password",
                    text: $confirmPassword
                )
                .textFieldStyle(AppTextFieldStyle())

                PrimaryButton(
                    title: "Update Password",
                    icon: "lock.fill"
                ) {
                    updatePassword()
                }
            }
            .padding(20)
        }
        .appBackground()
        .alert("Password Updated", isPresented: $showSuccess) {
            Button("Done") {
                dismiss()
            }
        } message: {
            Text("Your password has been changed successfully.")
        }
        .alert("Unable to Update", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(
                app.errorMessage
                ?? "Please check your password information."
            )
        }
    }

    private func updatePassword() {
        let success = app.changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
            confirmPassword: confirmPassword
        )

        if success {
            showSuccess = true
        } else {
            showError = true
        }
    }
}

// MARK: Notifications

struct NotificationsScreen: View {
    @EnvironmentObject var app: AppController

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    ScreenHeader(
                        title: "Notifications",
                        subtitle: "Updates about your reports and claims."
                    )

                    Spacer()
                }

                if !app.notifications.isEmpty {
                    Button("Mark All as Read") {
                        app.markAllNotificationsRead()
                    }
                    .foregroundStyle(AppTheme.crimson)
                }

                if app.notifications.isEmpty {
                    EmptyStateView(
                        icon: "bell",
                        title: "No notifications",
                        message: "You're all caught up."
                    )
                } else {
                    ForEach(app.notifications) { notification in
                        NotificationRow(
                            notification: notification
                        ) {
                            app.markNotificationRead(
                                notification.id
                            )
                        }
                    }
                }
            }
            .padding(20)
        }
        .appBackground()
    }
}

struct NotificationRow: View {
    let notification: AppNotification
    let markRead: () -> Void

    var body: some View {
        Button {
            markRead()
        } label: {
            HStack(alignment: .top, spacing: 13) {
                Image(
                    systemName:
                        notification.isRead
                        ? "bell"
                        : "bell.badge.fill"
                )
                .foregroundStyle(AppTheme.crimson)

                VStack(alignment: .leading, spacing: 5) {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(notification.message)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryPrimaryText)

                    Text(
                        notification.createdAt.formatted(
                            date: .abbreviated,
                            time: .shortened
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                }

                Spacer()
            }
            .padding(16)
            .background(
                notification.isRead
                ? AppTheme.card
                : AppTheme.crimsonSoft
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }
}

// MARK: Help

struct HelpSupportScreen: View {
    @Environment(\.openURL) private var openURL

    @State private var expandedFAQ: Int?

    private let faqs = [
        (
            "How do I report a lost item?",
            "Open the Report tab, choose Lost, complete the form, attach a photo if available, then submit the report."
        ),
        (
            "How do I report a found item?",
            "Open the Report tab, choose Found, enter the item information and submit it for employee verification."
        ),
        (
            "How do I claim an item?",
            "Open a verified found item and select I Think This Is Mine. Provide ownership verification information and submit your claim."
        ),
        (
            "How long does verification take?",
            "Reports and claims are reviewed by Lost & Found employees. The app shows the current verification status."
        ),
        (
            "Can I edit my report?",
            "Yes. Open My Items and select the report you want to edit."
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScreenHeader(
                    title: "Help & Support",
                    subtitle: "Frequently asked questions and support."
                )

                Text("FREQUENTLY ASKED QUESTIONS")
                    .font(.caption.bold())
                    .tracking(1)
                    .foregroundStyle(AppTheme.secondaryText)

                VStack(spacing: 0) {
                    ForEach(
                        Array(faqs.enumerated()),
                        id: \.offset
                    ) { index, faq in

                        Button {
                            withAnimation {
                                if expandedFAQ == index {
                                    expandedFAQ = nil
                                } else {
                                    expandedFAQ = index
                                }
                            }
                        } label: {
                            HStack {
                                Text(faq.0)
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.leading)

                                Spacer()

                                Image(
                                    systemName:
                                        expandedFAQ == index
                                        ? "chevron.up"
                                        : "chevron.down"
                                )
                                .foregroundStyle(AppTheme.secondaryText)
                            }
                            .padding(16)
                        }
                        .buttonStyle(.plain)

                        if expandedFAQ == index {
                            Text(faq.1)
                                .font(.subheadline)
                                .foregroundStyle(
                                    AppTheme.secondaryPrimaryText
                                )
                                .padding(
                                    .horizontal,
                                    16
                                )
                                .padding(
                                    .bottom,
                                    16
                                )
                        }

                        if index < faqs.count - 1 {
                            Divider()
                        }
                    }
                }
                .background(AppTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                Text("CONTACT SUPPORT")
                    .font(.caption.bold())
                    .tracking(1)
                    .foregroundStyle(AppTheme.secondaryText)

                Button {
                    if let url = URL(
                        string: "mailto:support@larping.edu"
                    ) {
                        openURL(url)
                    }
                } label: {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(AppTheme.crimson)

                        Text("support@larping.edu")
                            .foregroundStyle(.white)

                        Spacer()

                        Image(systemName: "arrow.up.right")
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    .padding(16)
                    .background(AppTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(20)
        }
        .appBackground()
    }
}

// MARK: About

struct AboutScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AppLogo()

                Text("Campus Lost & Found")
                    .font(.title.bold())
                    .foregroundStyle(.white)

                Text("Larping University")
                    .foregroundStyle(AppTheme.secondaryText)

                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundStyle(AppTheme.crimson)

                InfoCard(
                    title: "Purpose",
                    icon: "target"
                ) {
                    Text(
                        "Campus Lost & Found provides a centralized way for students to report lost or found belongings, search verified items, and submit ownership claims."
                    )
                }

                InfoCard(
                    title: "Privacy",
                    icon: "lock.shield"
                ) {
                    Text(
                        "Personal information should only be used for account access, report verification, claim processing, and related campus lost-and-found activities."
                    )
                }

                InfoCard(
                    title: "Community Guidelines",
                    icon: "person.3"
                ) {
                    Text(
                        "Provide truthful information, respect other users, and do not submit fraudulent reports or claims."
                    )
                }

                InfoCard(
                    title: "Terms",
                    icon: "doc.text"
                ) {
                    Text(
                        "Use the system responsibly and follow university policies when reporting, claiming, or handling found property."
                    )
                }
            }
            .foregroundStyle(AppTheme.secondaryPrimaryText)
            .padding(20)
        }
        .appBackground()
    }
}

struct InfoCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.headline.bold())
                .foregroundStyle(.white)

            content()
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: Rate

struct RateAppScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var rating = 0
    @State private var feedback = ""
    @State private var submitted = false

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                ScreenHeader(
                    title: "Rate the App",
                    subtitle: "Tell us about your experience."
                )

                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { star in
                        Button {
                            rating = star
                        } label: {
                            Image(
                                systemName:
                                    star <= rating
                                    ? "star.fill"
                                    : "star"
                            )
                            .font(.system(size: 35))
                            .foregroundStyle(
                                star <= rating
                                ? AppTheme.crimson
                                : AppTheme.secondaryText
                            )
                        }
                    }
                }

                Text(
                    rating == 0
                    ? "Tap a star to rate"
                    : "\(rating) out of 5 stars"
                )
                .foregroundStyle(AppTheme.secondaryText)

                TextEditor(text: $feedback)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(.white)
                    .frame(height: 160)
                    .padding()
                    .background(AppTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(alignment: .topLeading) {
                        if feedback.isEmpty {
                            Text("Optional feedback")
                                .foregroundStyle(
                                    AppTheme.secondaryText
                                )
                                .padding(20)
                                .allowsHitTesting(false)
                        }
                    }

                PrimaryButton(
                    title: "Submit Rating",
                    icon: "star.fill"
                ) {
                    guard rating > 0 else {
                        return
                    }

                    submitted = true
                }
            }
            .padding(20)
        }
        .appBackground()
        .alert(
            "Thank You!",
            isPresented: $submitted
        ) {
            Button("Done") {
                dismiss()
            }
        } message: {
            Text(
                "Your rating and feedback have been recorded for this demo."
            )
        }
    }
}