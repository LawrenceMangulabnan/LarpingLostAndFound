import SwiftUI

struct StudentHomeScreen: View {
    @EnvironmentObject private var app: AppController
    private var approved: [LostFoundItem] { app.items.filter { $0.status == .approved }.sorted { $0.createdAt > $1.createdAt } }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Welcome,\n\(app.currentUser?.fullName ?? "Student")").font(.largeTitle.bold())
                NavigationLink {
                    NotificationsScreen()
                } label: {
                    Label("Notifications (\(app.currentUser.map { app.unreadCount(for: $0.id) } ?? 0))", systemImage: "bell")
                }
                HStack {
                    NavigationLink { StudentBrowseScreen() } label: { StatCard(title: "Approved Items", value: approved.count, icon: "checkmark.circle") }
                    NavigationLink { StudentMyItemsScreen() } label: {
                        StatCard(title: "My Pending Reports", value: app.items.filter { $0.userID == app.currentUser?.id && $0.status == .pending }.count, icon: "clock")
                    }
                }.buttonStyle(.plain)
                Text("Recently Approved").font(.title2.bold())
                ForEach(Array(approved.prefix(5))) { item in
                    NavigationLink { StudentItemDetailScreen(item: item) } label: { ItemCard(item: item) }.buttonStyle(.plain)
                }
                if approved.isEmpty { Text("No approved items yet.") }
            }.padding()
        }.appBackground()
    }
}
