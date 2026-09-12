import Foundation

final class MockRepository: DataRepository {
    private var storedUsers: [User] = []
    private var storedItems: [LostFoundItem] = []
    private var storedClaims: [Claim] = []
    private var storedNotifications: [AppNotification] = []

    init() { seed() }

    private func daysAgo(_ value: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -value, to: Date()) ?? Date()
    }

    private func seed() {
        let student = User(fullName: "Alex Jordan", email: "student@larping.edu", password: "123456", universityID: "2024-0042", role: .student)
        let employee = User(fullName: "Jamie Rivera", email: "employee@larping.edu", password: "123456", universityID: "EMP-0042", role: .employee)
        let jordan = User(fullName: "Jordan M.", email: "jordan@larping.edu", password: "123456", universityID: "2024-1101", role: .student)
        let alexT = User(fullName: "Alex T.", email: "alext@larping.edu", password: "123456", universityID: "2024-1102", role: .student)
        let riley = User(fullName: "Riley K.", email: "riley@larping.edu", password: "123456", universityID: "2024-1103", role: .student)
        let chris = User(fullName: "Chris L.", email: "chris@larping.edu", password: "123456", universityID: "2024-1104", role: .student)
        let morgan = User(fullName: "Morgan Lee", email: "morgan@larping.edu", password: "123456", universityID: "2024-1105", role: .student)
        storedUsers = [student, employee, jordan, alexT, riley, chris, morgan]

        storedItems = [
            LostFoundItem(userID: student.id, photoURL: "https://images.unsplash.com/photo-1627123424574-724758594e93?w=600&h=600&fit=crop&auto=format", itemName: "Black Wallet", category: .ids, location: "Main Library", date: daysAgo(3), description: "Black folding wallet with university cards.", type: .lost, status: .approved, createdAt: daysAgo(3)),
            LostFoundItem(userID: alexT.id, photoURL: "https://images.unsplash.com/photo-1770292170233-5d9e235ec739?w=600&h=600&fit=crop&auto=format", itemName: "AirPods Case", category: .electronics, location: "Student Union, Café Area", date: daysAgo(1), description: "White AirPods Pro charging case, no earbuds inside. Found on a corner table near the espresso bar. Small scuff on the hinge.", type: .found, status: .approved, createdAt: daysAgo(1)),
            LostFoundItem(userID: jordan.id, photoURL: "https://images.unsplash.com/photo-1579014134953-1580d7f123f3?w=600&h=600&fit=crop&auto=format", itemName: "Black Leather Wallet", category: .other, customCategory: "Wallet", location: "Main Library, 2nd Floor", date: daysAgo(3), description: "Black bifold leather wallet with worn edges, found near the east study carrels on the second floor. Contains a student ID and several cards.", type: .found, status: .approved, createdAt: daysAgo(3)),
            LostFoundItem(userID: student.id, photoURL: "https://images.unsplash.com/photo-1650500426868-27a68714a4a4?w=600&h=600&fit=crop&auto=format", itemName: "Blue Backpack", category: .bags, location: "Science Building, Room 204", date: daysAgo(4), description: "Navy blue Jansport backpack, keychain on top handle. Left after Tuesday 2 pm lecture. Has textbooks and a MacBook charger inside.", type: .lost, status: .approved, createdAt: daysAgo(4)),
            LostFoundItem(userID: employee.id, photoURL: "https://images.unsplash.com/photo-1631164159497-3a2408944c35?w=600&h=600&fit=crop&auto=format", itemName: "Key Bundle with Red Lanyard", category: .keys, location: "Athletics Center, Lobby", date: Date(), description: "Set of keys on a red university-branded lanyard — two apartment keys, a car key, and a mailbox key. Found on the bench near the front desk.", type: .found, status: .approved, createdAt: Date()),
            LostFoundItem(userID: riley.id, photoURL: "https://images.unsplash.com/photo-1565935691050-6814cad6fba7?w=600&h=600&fit=crop&auto=format", itemName: "Black Umbrella", category: .other, customCategory: "Umbrella", location: "Engineering Hall, Main Entrance", date: daysAgo(5), description: "Standard black compact umbrella, rubber curved handle. Left in the umbrella rack at the Engineering Hall main entrance after Friday's rain.", type: .found, status: .pending, createdAt: daysAgo(5)),
            LostFoundItem(userID: employee.id, photoURL: "https://images.unsplash.com/photo-1623795457671-600b1223c2db?w=600&h=600&fit=crop&auto=format", itemName: "Student ID", category: .ids, location: "Campus Bookstore, Checkout", date: daysAgo(1), description: "University student ID for Maya Chen, #2024-8819. Found on the floor in front of the checkout counter.", type: .found, status: .approved, createdAt: daysAgo(1)),
            LostFoundItem(userID: jordan.id, photoURL: "https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=600&h=600&fit=crop&auto=format", itemName: "USB Flash Drive", category: .electronics, location: "Computer Lab A", date: daysAgo(2), description: "Black 32GB USB flash drive with a red cap, found at a lab workstation.", type: .found, status: .approved, createdAt: daysAgo(2)),
            LostFoundItem(userID: chris.id, photoURL: "https://images.unsplash.com/photo-1577733975197-3b950ca5cabe?w=600&h=600&fit=crop&auto=format", itemName: "Gray Laptop Backpack", category: .bags, location: "Campus Coffee, Outdoor Patio", date: daysAgo(2), description: "Large gray laptop backpack, multiple exterior pockets. Left on a patio chair. The front pocket has a broken zipper pull.", type: .lost, status: .pending, createdAt: daysAgo(2)),
            LostFoundItem(userID: student.id, photoURL: "https://images.unsplash.com/photo-1585565804112-f201f68c48b4?w=600&h=600&fit=crop&auto=format", itemName: "Apple EarPods (wired)", category: .electronics, location: "Performing Arts, Studio B", date: daysAgo(6), description: "White Apple wired EarPods in original case. Found on a piano bench after a rehearsal.", type: .found, status: .rejected, createdAt: daysAgo(6))
        ]

        if let wallet = storedItems.first(where: { $0.itemName == "Black Leather Wallet" }),
           let keys = storedItems.first(where: { $0.itemName == "Key Bundle with Red Lanyard" }) {
            storedClaims = [
                Claim(itemID: wallet.id, studentID: student.id, appearance: "Black bifold, worn right corner, silver clasp", contents: "Chase debit card ending 7842, $23 cash, small photo booth strip", context: "Lost it after afternoon study session on Aug 30", verificationInformation: "Black bifold, worn right corner, silver clasp"),
                Claim(itemID: keys.id, studentID: morgan.id, appearance: "Red university lanyard with bunch of 4 keys", contents: "Two silver apartment keys, black Honda car key, small gold mailbox key", context: "Left it on the bench after my workout on Sep 1", verificationInformation: "Red university lanyard with 4 keys")
            ]
        }

        storedNotifications = [
            AppNotification(userID: student.id, title: "Report Approved", message: "Your lost item report for 'Blue Backpack' was approved.", createdAt: daysAgo(0), isRead: false, relatedItemID: storedItems.first { $0.itemName == "Blue Backpack" }?.id),
            AppNotification(userID: student.id, title: "New Claim Received", message: "A claim has been submitted for your found item.", createdAt: daysAgo(0), isRead: false),
            AppNotification(userID: student.id, title: "Claim Pending", message: "Your claim for 'Black Leather Wallet' is pending verification.", createdAt: daysAgo(1), isRead: true, relatedItemID: storedItems.first { $0.itemName == "Black Leather Wallet" }?.id),
            AppNotification(userID: student.id, title: "Claim Approved", message: "Your claim was approved! Visit the Lost & Found office to collect your item.", createdAt: daysAgo(2), isRead: true),
            AppNotification(userID: employee.id, title: "New Report", message: "Black Umbrella needs verification.", createdAt: daysAgo(1), isRead: false, relatedItemID: storedItems.first { $0.itemName == "Black Umbrella" }?.id)
        ]
    }

    func fetchUsers() -> [User] { storedUsers }
    func saveUser(_ user: User) { storedUsers.append(user) }
    func updateUser(_ user: User) {
        guard let index = storedUsers.firstIndex(where: { $0.id == user.id }) else { return }
        storedUsers[index] = user
    }
    func fetchItems() -> [LostFoundItem] { storedItems }
    func saveItem(_ item: LostFoundItem) { storedItems.append(item) }
    func updateItem(_ item: LostFoundItem) {
        guard let index = storedItems.firstIndex(where: { $0.id == item.id }) else { return }
        storedItems[index] = item
    }
    func deleteItem(_ id: UUID) {
        storedItems.removeAll { $0.id == id }
        storedClaims.removeAll { $0.itemID == id }
    }
    func fetchClaims() -> [Claim] { storedClaims }
    func saveClaim(_ claim: Claim) { storedClaims.append(claim) }
    func updateClaim(_ claim: Claim) {
        guard let index = storedClaims.firstIndex(where: { $0.id == claim.id }) else { return }
        storedClaims[index] = claim
    }
    func fetchNotifications() -> [AppNotification] { storedNotifications }
    func saveNotification(_ notification: AppNotification) { storedNotifications.append(notification) }
    func updateNotification(_ notification: AppNotification) {
        guard let index = storedNotifications.firstIndex(where: { $0.id == notification.id }) else { return }
        storedNotifications[index] = notification
    }
}
