import Foundation

protocol DataRepository {
    func fetchUsers() -> [User]
    func saveUser(_ user: User)
    func updateUser(_ user: User)

    func fetchItems() -> [LostFoundItem]
    func saveItem(_ item: LostFoundItem)
    func updateItem(_ item: LostFoundItem)
    func deleteItem(_ id: UUID)

    func fetchClaims() -> [Claim]
    func saveClaim(_ claim: Claim)
    func updateClaim(_ claim: Claim)

    func fetchNotifications() -> [AppNotification]
    func saveNotification(_ notification: AppNotification)
    func updateNotification(_ notification: AppNotification)
}
