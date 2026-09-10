import SwiftUI

struct EmployeeDashboardScreen: View {
    @EnvironmentObject private var app: AppController
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Dashboard").font(.largeTitle.bold())
                Text("Welcome, \(app.currentUser?.fullName ?? "Staff")")
                NavigationLink("Notifications", systemImage: "bell") { NotificationsScreen() }
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    NavigationLink { EmployeeReportsScreen(initialStatus: .pending) } label: {
                        StatCard(title: "Pending Reports", value: app.items.filter { $0.status == .pending }.count, icon: "doc.badge.clock")
                    }
                    NavigationLink { EmployeeClaimsScreen(showPendingOnly: true) } label: {
                        StatCard(title: "Pending Claims", value: app.claims.filter { $0.status == .pending }.count, icon: "clock")
                    }
                    NavigationLink { EmployeeItemsScreen(initialStatus: .approved) } label: {
                        StatCard(title: "Approved Items", value: app.items.filter { $0.status == .approved }.count, icon: "checkmark.circle")
                    }
                    NavigationLink { EmployeeItemsScreen(initialStatus: .claimed) } label: {
                        StatCard(title: "Claimed Items", value: app.items.filter { $0.status == .claimed }.count, icon: "shippingbox")
                    }
                }.buttonStyle(.plain)
                Text("Recent Pending Reports").font(.title2.bold())
                ForEach(Array(app.items.filter { $0.status == .pending }.sorted { $0.createdAt > $1.createdAt }.prefix(5))) { item in
                    NavigationLink { EmployeeReportReviewScreen(item: item) } label: { ItemCard(item: item) }.buttonStyle(.plain)
                }
                if !app.items.contains(where: { $0.status == .pending }) { Text("All reports reviewed.") }
            }.padding()
        }.appBackground()
    }
}
