import SwiftUI

struct NotificationsScreen: View {
    @EnvironmentObject private var app: AppController
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Notifications").font(.largeTitle.bold())
                if let user = app.currentUser {
                    Button("Read All") { app.markAllNotificationsRead() }.disabled(app.unreadCount(for: user.id) == 0)
                    ForEach(app.notifications(for: user.id)) { notification in
                        Button { app.markNotificationRead(notification) } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Label(notification.title, systemImage: notification.isRead ? "envelope.open" : "envelope.badge").font(.headline)
                                Text(notification.message)
                                Text(notification.createdAt.formatted()).font(.caption)
                                Text(notification.isRead ? "Read" : "Unread").font(.caption.bold())
                            }.frame(maxWidth: .infinity, alignment: .leading).appCard()
                        }.buttonStyle(.plain)
                    }
                    if app.notifications(for: user.id).isEmpty { ContentUnavailableView("No notifications", systemImage: "bell") }
                }
            }.padding()
        }.appBackground()
    }
}
