import SwiftUI

struct NotificationsScreen: View {
    @EnvironmentObject private var app: AppController
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if let user = app.currentUser {
                    Button("Mark All Read") { app.markAllNotificationsRead() }
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.red)
                        .disabled(app.unreadCount(for: user.id) == 0)
                    ForEach(app.notifications(for: user.id)) { note in
                        Group {
                            if let itemID = note.relatedItemID, let item = app.items.first(where: { $0.id == itemID }) {
                                NavigationLink { StudentItemDetailScreen(item: item) } label: { row(note) }
                            } else {
                                Button { app.markNotificationRead(note) } label: { row(note) }
                            }
                        }.buttonStyle(.plain)
                    }
                    if app.notifications(for: user.id).isEmpty {
                        EmptyState(emoji: "🔔", title: "No notifications")
                    }
                }
            }.padding(16)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Notifications")
    }

    private func row(_ note: AppNotification) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(note.title.contains("Approved") ? "✅" : note.title.contains("Claim") ? "📋" : "🔔")
                .frame(width: 40, height: 40)
                .background(note.isRead ? AppColors.cardHi : AppColors.blueLight)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(note.title).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.label)
                    if !note.isRead { Circle().fill(AppColors.blue).frame(width: 8, height: 8) }
                }
                Text(note.message).font(.system(size: 13)).foregroundStyle(AppColors.label3)
                Text(note.createdAt.formatted()).font(.system(size: 12)).foregroundStyle(AppColors.label3)
            }
            Spacer()
        }
        .padding(14)
        .background(note.isRead ? AppColors.card : AppColors.blueGhost)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(note.isRead ? AppColors.sep : AppColors.blue.opacity(0.2)))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture { app.markNotificationRead(note) }
    }
}
