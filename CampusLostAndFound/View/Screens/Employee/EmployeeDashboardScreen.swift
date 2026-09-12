import SwiftUI

struct EmployeeDashboardScreen: View {
    @EnvironmentObject private var app: AppController
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Lost & Found Staff").font(.system(size: 12, weight: .medium)).foregroundStyle(.white.opacity(0.35))
                        Text(app.currentUser?.fullName ?? "Staff").font(.system(size: 24, weight: .black)).foregroundStyle(.white)
                        Text("Employee ID: \(app.currentUser?.universityID ?? "")").font(.system(size: 12)).foregroundStyle(.white.opacity(0.35))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        Button { app.openEmployee(.profile) } label: {
                            Text(app.currentUser?.initials ?? "JR").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                                .frame(width: 44, height: 44).background(.white.opacity(0.1)).overlay(Circle().stroke(.white.opacity(0.15), lineWidth: 1.5)).clipShape(Circle())
                        }
                        Text("🏢 Employee").font(.system(size: 11, weight: .semibold)).foregroundStyle(AppColors.red)
                            .padding(.horizontal, 10).padding(.vertical, 4).background(AppColors.red.opacity(0.2)).overlay(Capsule().stroke(AppColors.red.opacity(0.27))).clipShape(Capsule())
                    }
                }
                .padding(20).padding(.bottom, 28)
                .staffHeader()

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("System Overview").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.label3).textCase(.uppercase)
                        HStack(spacing: 8) {
                            StatCard(title: "Pending", value: app.items.filter { $0.status == .pending }.count, color: AppColors.orange, bg: AppColors.orangeLight) { app.openEmployee(.reports) }
                            StatCard(title: "Lost", value: app.items.filter { $0.type == .lost }.count, color: AppColors.red, bg: AppColors.redLight) { app.openEmployee(.items) }
                            StatCard(title: "Found", value: app.items.filter { $0.type == .found }.count, color: AppColors.green, bg: AppColors.greenLight) { app.openEmployee(.items) }
                        }
                        HStack(spacing: 8) {
                            StatCard(title: "Pending Claims", value: app.claims.filter { $0.status == .pending }.count, color: AppColors.blue, bg: AppColors.blueLight) { app.openEmployee(.claims) }
                            StatCard(title: "Returned", value: app.items.filter { $0.status == .returned }.count, color: AppColors.purple, bg: AppColors.purpleLight) { app.openEmployee(.items) }
                        }
                    }
                    .padding(16).background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 18))
                    .offset(y: -12)

                    Text("Quick Actions").font(.system(size: 17, weight: .bold)).foregroundStyle(AppColors.label)
                    action("📋", "Review Reports", "\(app.items.filter { $0.status == .pending }.count) pending", AppColors.orangeLight, AppColors.orange) { app.openEmployee(.reports) }
                    action("🔍", "Review Claims", "\(app.claims.filter { $0.status == .pending }.count) pending", AppColors.blueLight, AppColors.blue) { app.openEmployee(.claims) }
                    action("📦", "Manage Items", "\(app.items.count) total", AppColors.greenLight, AppColors.green) { app.openEmployee(.items) }

                    HStack {
                        Text("Recent Reports").font(.system(size: 17, weight: .bold)).foregroundStyle(AppColors.label)
                        Spacer()
                        Button("View All") { app.openEmployee(.reports) }.foregroundStyle(AppColors.red)
                    }
                    ForEach(Array(app.items.filter { $0.status == .pending }.sorted { $0.createdAt > $1.createdAt }.prefix(3))) { item in
                        NavigationLink { EmployeeReportReviewScreen(item: item) } label: { ItemCard(item: item) }.buttonStyle(.plain)
                    }
                    if !app.items.contains(where: { $0.status == .pending }) {
                        Text("All reports reviewed.").foregroundStyle(AppColors.label3)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private func action(_ icon: String, _ title: String, _ sub: String, _ bg: Color, _ color: Color, tap: @escaping () -> Void) -> some View {
        Button(action: tap) {
            HStack(spacing: 12) {
                Text(icon).frame(width: 48, height: 48).background(bg).clipShape(RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 16, weight: .semibold)).foregroundStyle(AppColors.label)
                    Text(sub).font(.system(size: 13, weight: .medium)).foregroundStyle(color)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(AppColors.label3)
            }
            .padding(16).background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 16))
        }.buttonStyle(.plain)
    }
}
