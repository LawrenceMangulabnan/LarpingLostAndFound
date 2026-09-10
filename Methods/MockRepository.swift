import Foundation

final class MockRepository: DataRepository {

    private var storedUsers: [User] = []
    private var storedItems: [LostFoundItem] = []
    private var storedClaims: [Claim] = []
    private var storedNotifications: [AppNotification] = []

    init() {
        seed()
    }

    private func seed() {
        let student = User(
            fullName: "Demo Student",
            email: "student@larping.edu",
            password: "123456",
            universityID: "STU-2026-001",
            role: .student
        )

        let employee = User(
            fullName: "Lost & Found Staff",
            email: "employee@larping.edu",
            password: "123456",
            universityID: "EMP-001",
            role: .employee
        )

        storedUsers = [student, employee]

        storedItems = [
            LostFoundItem(userID: student.id, itemName: "Black Wallet", category: .ids, location: "Main Library", date: Date(), description: "Black folding wallet with university cards.", type: .lost, status: .approved),
            LostFoundItem(userID: employee.id, itemName: "AirPods Case", category: .electronics, location: "CCMS Hallway", date: Date(), description: "White charging case found near the hallway benches.", type: .found, status: .approved),
            LostFoundItem(userID: student.id, itemName: "Blue Umbrella", category: .other, customCategory: "Umbrella", location: "Student Center", date: Date(), description: "Blue umbrella with a wooden handle.", type: .lost, status: .pending)
        ]
    }
    func fetchUsers() -> [User] {
        storedUsers
    }

    func saveUser(_ user: User) {
        storedUsers.append(user)
    }

    func updateUser(_ user: User) {
        guard let index = storedUsers.firstIndex(where: { $0.id == user.id }) else {
            return
        }

        storedUsers[index] = user
    }

    func fetchItems() -> [LostFoundItem] {
        storedItems
    }

    func saveItem(_ item: LostFoundItem) {
        storedItems.append(item)
    }

    func updateItem(_ item: LostFoundItem) {
        guard let index = storedItems.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        storedItems[index] = item
    }

    func deleteItem(_ id: UUID) {
        storedItems.removeAll { $0.id == id }
        storedClaims.removeAll { $0.itemID == id }
    }

    func fetchClaims() -> [Claim] {
        storedClaims
    }

    func saveClaim(_ claim: Claim) {
        storedClaims.append(claim)
    }

    func updateClaim(_ claim: Claim) {
        guard let index = storedClaims.firstIndex(where: { $0.id == claim.id }) else {
            return
        }

        storedClaims[index] = claim
    }

    func fetchNotifications() -> [AppNotification] {
        storedNotifications
    }

    func saveNotification(_ notification: AppNotification) {
        storedNotifications.append(notification)
    }

    func updateNotification(_ notification: AppNotification) {
        guard let index = storedNotifications.firstIndex(where: { $0.id == notification.id }) else {
            return
        }

        storedNotifications[index] = notification
    }
}

