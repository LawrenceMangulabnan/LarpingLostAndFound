import Foundation

protocol DataRepository {
    func users() -> [User]
    func saveUser(_ user: User)
    func updateUser(_ user: User)

    func items() -> [LostFoundItem]
    func saveItem(_ item: LostFoundItem)
    func updateItem(_ item: LostFoundItem)
    func deleteItem(_ id: UUID)

    func claims() -> [Claim]
    func saveClaim(_ claim: Claim)
    func updateClaim(_ claim: Claim)

    func notifications() -> [NotificationItem]
    func saveNotification(_ notification: NotificationItem)
    func updateNotification(_ notification: NotificationItem)
}