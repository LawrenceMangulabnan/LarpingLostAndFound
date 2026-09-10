import Foundation

final class MockRepository: DataRepository {

    private var storedUsers: [User] = []
    private var storedItems: [LostFoundItem] = []
    private var storedClaims: [Claim] = []
    private var storedNotifications: [NotificationItem] = []

    init() {
        seed()
    }

    private func seed() {
        let student = User(
            fullName: "Lawrence Student",
            email: "student@larping.edu",
            password: "123456",
            universityID: "LU-2026-001",
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

        let samples: [
            (
                String,
                ItemCategory,
                String,
                ItemType,
                String
            )
        ] = [
            ("Black Wallet", .other, "Wallet", .found, "Library"),
            ("iPhone", .electronics, "", .lost, "Computer Laboratory"),
            ("Student ID", .ids, "", .lost, "Main Building"),
            ("Black Backpack", .bags, "", .found, "Cafeteria"),
            ("AirPods", .electronics, "", .found, "Gymnasium"),
            ("House Keys", .keys, "", .lost, "Parking Area"),
            ("Black Jacket", .clothing, "", .found, "Student Center"),
            ("Laptop Charger", .electronics, "", .found, "Classroom Building")
        ]

        for (index, sample) in samples.enumerated() {
            storedItems.append(
                LostFoundItem(
                    userID: student.id,
                    itemName: sample.0,
                    category: sample.1,
                    customCategory: sample.2,
                    location: sample.4,
                    date: Calendar.current.date(
                        byAdding: .day,
                        value: -index,
                        to: Date()
                    ) ?? Date(),
                    description: "Sample Lost & Found item for testing.",
                    type: sample.3,
                    status: .approved
                )
            )
        }
    }

    func users() -> [User] {
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

    func items() -> [LostFoundItem] {
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

    func claims() -> [Claim] {
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

    func notifications() -> [NotificationItem] {
        storedNotifications
    }

    func saveNotification(_ notification: NotificationItem) {
        storedNotifications.append(notification)
    }

    func updateNotification(_ notification: NotificationItem) {
        guard let index = storedNotifications.firstIndex(where: { $0.id == notification.id }) else {
            return
        }

        storedNotifications[index] = notification
    }
}