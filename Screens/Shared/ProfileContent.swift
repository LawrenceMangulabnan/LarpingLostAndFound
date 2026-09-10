import SwiftUI

struct ProfileContent: View {
    @EnvironmentObject private var app: AppController
    @State private var showLogout = false
    var body: some View {
        Form {
            Section {
                Text(app.currentUser?.fullName ?? "").font(.title2.bold())
                Text(app.currentUser?.email ?? "")
                Text(app.currentUser?.universityID ?? "")
                Text(app.currentUser?.role.rawValue ?? "").foregroundStyle(AppColors.secondaryText)
            }
            Section("Account") {
                NavigationLink { EditProfileScreen() } label: { SettingsRow(title: "Edit Profile", icon: "person") }
                NavigationLink { ChangePasswordScreen() } label: { SettingsRow(title: "Change Password", icon: "lock") }
                NavigationLink { NotificationsScreen() } label: { SettingsRow(title: "Notifications", icon: "bell") }
            }
            Section("Support") {
                NavigationLink { HelpSupportScreen() } label: { SettingsRow(title: "Help & Support", icon: "questionmark.circle") }
                NavigationLink { AboutScreen() } label: { SettingsRow(title: "About", icon: "info.circle") }
                NavigationLink { RateAppScreen() } label: { SettingsRow(title: "Rate the App", icon: "star") }
            }
            Button("Logout", role: .destructive) { showLogout = true }
        }.appBackground().navigationTitle("Profile")
            .confirmationDialog("Log out?", isPresented: $showLogout, titleVisibility: .visible) {
                Button("Logout", role: .destructive) { app.logout() }
                Button("Cancel", role: .cancel) { showLogout = false }
            }
    }
}

