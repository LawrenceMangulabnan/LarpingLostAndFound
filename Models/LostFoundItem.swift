import Foundation

struct LostFoundItem: Identifiable, Codable, Equatable {
    let id: UUID
    var userID: UUID
    var photoData: Data?
    var itemName: String
    var category: ItemCategory
    var customCategory: String
    var location: String
    var date: Date
    var description: String
    var type: ItemType
    var status: ItemStatus
    let createdAt: Date

    init(
        id: UUID = UUID(),
        userID: UUID,
        photoData: Data? = nil,
        itemName: String,
        category: ItemCategory,
        customCategory: String = "",
        location: String,
        date: Date,
        description: String,
        type: ItemType,
        status: ItemStatus = .pending,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userID = userID
        self.photoData = photoData
        self.itemName = itemName
        self.category = category
        self.customCategory = customCategory
        self.location = location
        self.date = date
        self.description = description
        self.type = type
        self.status = status
        self.createdAt = createdAt
    }

    var displayCategory: String {
        if category == .other && !customCategory.isEmpty {
            return customCategory
        }

        return category.rawValue
    }
}