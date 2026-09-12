import SwiftUI

struct StudentProfileScreen: View {
    var body: some View { ProfileContent(kind: .student) }
}

struct EmployeeProfileScreen: View {
    var body: some View { ProfileContent(kind: .employee) }
}

enum ProfileKind { case student, employee }

struct ProfileContent: View {
    @EnvironmentObject private var app: AppController
    let kind: ProfileKind
    @State private var logout = false
    var body: some View {
        ScrollView {
            if let user = app.currentUser {
                VStack(spacing: 20) {
                    headerCard(user)
                    accountSection
                    activitySection(user)
                    notificationsSection(user)
                    appSection
                    logoutButton
                    footerText
                }.padding(16).padding(.bottom, 32)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("Log Out?", isPresented: $logout, titleVisibility: .visible) {
            Button("Log Out", role: .destructive) { app.logout() }
            Button("Cancel", role: .cancel) {}
        } message: { Text("Are you sure you want to log out?") }
    }

    @ViewBuilder private func headerCard(_ user: User) -> some View {
        HStack(spacing: 16) {
            NavigationLink { EditProfileScreen() } label: { AvatarView(user: user, size: 68) }
            VStack(alignment: .leading, spacing: 6) {
                Text(user.fullName).font(.system(size: 18, weight: .bold)).foregroundStyle(AppColors.label)
                Text(user.email).font(.system(size: 13)).foregroundStyle(AppColors.label3)
                HStack(spacing: 8) {
                    let roleColor: Color = kind == .student ? AppColors.red : AppColors.green
                    let roleBg: Color = kind == .student ? AppColors.redLight : AppColors.greenLight
                    Text("\(user.role.emoji) \(user.role.shortLabel)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(roleColor)
                        .padding(.horizontal, 10).padding(.vertical, 3)
                        .background(roleBg).clipShape(Capsule())
                    Text(user.universityID).font(.system(size: 11, weight: .semibold)).foregroundStyle(AppColors.label3)
                        .padding(.horizontal, 10).padding(.vertical, 3).background(AppColors.cardHi).clipShape(Capsule())
                }
            }
            Spacer()
            NavigationLink { EditProfileScreen() } label: {
                Image(systemName: "pencil").foregroundStyle(AppColors.red)
                    .frame(width: 36, height: 36).background(AppColors.redGhost).clipShape(Circle())
            }
        }
        .padding(16).background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 20))
    }

    @ViewBuilder private var accountSection: some View {
        SettingsSection(title: "Account") {
            NavigationLink { EditProfileScreen() } label: { SettingsRow(title: "Edit Profile", icon: "✏️") }
            Divider().background(AppColors.sep)
            NavigationLink { ChangePasswordScreen() } label: { SettingsRow(title: "Change Password", icon: "🔒") }
        }
    }

    @ViewBuilder private func activitySection(_ user: User) -> some View {
        if kind == .student {
            let lostCount = app.items.filter { $0.userID == user.id && $0.type == .lost }.count
            let foundCount = app.items.filter { $0.userID == user.id && $0.type == .found }.count
            let claimCount = app.claims(for: user.id).count
            SettingsSection(title: "My Activity") {
                Button { app.openStudent(.myItems) } label: { SettingsRow(title: "My Lost Items", icon: "🔍", value: "\(lostCount)") }
                Divider().background(AppColors.sep)
                Button { app.openStudent(.myItems) } label: { SettingsRow(title: "My Found Items", icon: "✋", value: "\(foundCount)") }
                Divider().background(AppColors.sep)
                Button { app.openStudent(.myItems) } label: { SettingsRow(title: "My Claims", icon: "📋", value: "\(claimCount)") }
            }
        } else {
            let pendingReports = app.items.filter { $0.status == .pending }.count
            let pendingClaims = app.claims.filter { $0.status == .pending }.count
            let managedItems = app.items.count
            SettingsSection(title: "Management") {
                Button { app.openEmployee(.reports) } label: { SettingsRow(title: "Pending Reports", icon: "📋", value: "\(pendingReports)") }
                Divider().background(AppColors.sep)
                Button { app.openEmployee(.claims) } label: { SettingsRow(title: "Pending Claims", icon: "🔍", value: "\(pendingClaims)") }
                Divider().background(AppColors.sep)
                Button { app.openEmployee(.items) } label: { SettingsRow(title: "Managed Items", icon: "📦", value: "\(managedItems)") }
            }
        }
    }

    @ViewBuilder private func notificationsSection(_ user: User) -> some View {
        let unread = app.unreadCount(for: user.id)
        let unreadLabel = unread > 0 ? "\(unread) new" : ""
        SettingsSection(title: "Notifications") {
            NavigationLink { NotificationsScreen() } label: {
                SettingsRow(title: "Notifications", icon: "🔔", value: unreadLabel)
            }
            Divider().background(AppColors.sep)
            if kind == .student {
                toggle("💬", "Item Match Alerts", $app.itemMatchAlerts)
                Divider().background(AppColors.sep)
                toggle("📬", "Claim Status Updates", $app.claimStatusUpdates)
                Divider().background(AppColors.sep)
                toggle("📍", "New Items Nearby", $app.newItemsNearby)
            } else {
                toggle("📨", "New Report Submissions", $app.newReportAlerts)
                Divider().background(AppColors.sep)
                toggle("🔔", "New Claim Requests", $app.newClaimAlerts)
                Divider().background(AppColors.sep)
                toggle("🔄", "Daily Summary", $app.dailySummary)
            }
        }
    }

    @ViewBuilder private var appSection: some View {
        SettingsSection(title: "App") {
            NavigationLink { HelpSupportScreen() } label: { SettingsRow(title: "Help & Support", icon: "❓") }
            Divider().background(AppColors.sep)
            NavigationLink { AboutScreen() } label: { SettingsRow(title: "About Campus Lost & Found", icon: "ℹ️", value: "v1.0.0") }
            Divider().background(AppColors.sep)
            NavigationLink { RateAppScreen() } label: { SettingsRow(title: "Rate the App", icon: "⭐") }
        }
    }

    @ViewBuilder private var logoutButton: some View {
        Button { logout = true } label: {
            Text("Log Out").font(.system(size: 17, weight: .semibold)).foregroundStyle(AppColors.red)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(AppColors.redLight).clipShape(RoundedRectangle(cornerRadius: 16))
        }.buttonStyle(.plain)
    }

    @ViewBuilder private var footerText: some View {
        let text = kind == .student ? "Larping University · Campus Lost & Found" : "Larping University · Lost & Found Office"
        Text(text).font(.system(size: 12)).foregroundStyle(AppColors.label3)
    }

    private func toggle(_ icon: String, _ title: String, _ value: Binding<Bool>) -> some View {
        HStack {
            Text(icon).frame(width: 24)
            Text(title).foregroundStyle(AppColors.label).font(.system(size: 15))
            Spacer()
            Toggle("", isOn: value).labelsHidden().tint(AppColors.green)
        }.padding(.horizontal, 16).padding(.vertical, 8)
    }
}
