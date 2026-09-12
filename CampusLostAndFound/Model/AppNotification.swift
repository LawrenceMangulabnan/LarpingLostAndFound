import Foundation

struct AppNotification: Identifiable, Codable, Equatable {
    var id = UUID()
    var userID: UUID
    var title: String
    var message: String
    var createdAt = Date()
    var isRead = false
    var relatedItemID: UUID?
}
