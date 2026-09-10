import Foundation

struct NotificationItem: Identifiable, Codable, Equatable {
    let id: UUID
    var userID: UUID
    var title: String
    var message: String
    var date: Date
    var isRead: Bool

    init(
        id: UUID = UUID(),
        userID: UUID,
        title: String,
        message: String,
        date: Date = Date(),
        isRead: Bool = false
    ) {
        self.id = id
        self.userID = userID
        self.title = title
        self.message = message
        self.date = date
        self.isRead = isRead
    }
}