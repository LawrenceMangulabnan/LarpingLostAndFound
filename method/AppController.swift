import Foundation
import Combine

@MainActor
final class AppController: ObservableObject {

    @Published private(set) var currentUser: User?
    @Published private(set) var allUsers: [User] = []
    @Published private(set) var allItems: [LostFoundItem] = []
    @Published private(set) var allClaims: [Claim] = []
    @Published private(set) var allNotifications: [NotificationItem] = []

    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let repository: DataRepository

    init(repository: DataRepository = MockRepository()) {
        self.repository = repository
        reload()
    }

    func reload() {
        allUsers = repository.users()
        allItems = repository.items()
        allClaims = repository.claims()
        allNotifications = repository.notifications()
    }

    // MARK: Authentication

    func login(
        email: String,
        password: String,
        role: UserRole
    ) -> Bool {

        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return false
        }

        if let existingUser = allUsers.first(where: {
            $0.email.lowercased() == cleanEmail.lowercased()
                && $0.password == password
                && $0.role == role
        }) {
            currentUser = existingUser
            errorMessage = nil
            return true
        }

        let testUser = User(
            fullName: role == .student ? "Test Student" : "Test Employee",
            email: cleanEmail,
            password: password,
            universityID: "TEST-001",
            role: role
        )

        repository.saveUser(testUser)
        reload()
        currentUser = testUser

        return true
    }

    func signup(
        fullName: String,
        universityID: String,
        email: String,
        password: String,
        confirmPassword: String,
        role: UserRole
    ) -> Bool {

        let name = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let id = universityID.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty, !id.isEmpty, !cleanEmail.isEmpty else {
            errorMessage = "Please complete all required fields."
            return false
        }

        guard !password.isEmpty else {
            errorMessage = "Password cannot be empty."
            return false
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return false
        }

        if allUsers.contains(where: {
            $0.email.lowercased() == cleanEmail.lowercased()
        }) {
            errorMessage = "That email is already registered."
            return false
        }

        let user = User(
            fullName: name,
            email: cleanEmail,
            password: password,
            universityID: id,
            role: role
        )

        repository.saveUser(user)
        reload()

        currentUser = user
        successMessage = "Account created successfully."

        return true
    }

    func logout() {
        currentUser = nil
        errorMessage = nil
    }

    // MARK: Items

    func addItem(
        itemName: String,
        category: ItemCategory,
        customCategory: String,
        location: String,
        date: Date,
        description: String,
        type: ItemType,
        photoData: Data?
    ) -> Bool {

        guard let user = currentUser else {
            return false
        }

        guard !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter the item name."
            return false
        }

        guard !location.isEmpty else {
            errorMessage = "Please select a location."
            return false
        }

        if category == .other &&
            customCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

            errorMessage = "Please enter the custom category."
            return false
        }

        let item = LostFoundItem(
            userID: user.id,
            photoData: photoData,
            itemName: itemName,
            category: category,
            customCategory: customCategory,
            location: location,
            date: date,
            description: description,
            type: type,
            status: .pending
        )

        repository.saveItem(item)
        reload()

        addNotification(
            userID: user.id,
            title: "Report Submitted",
            message: "Your \(type.rawValue.lowercased()) report is pending verification."
        )

        successMessage = "Report submitted successfully."

        return true
    }

    func updateItem(_ item: LostFoundItem) {
        repository.updateItem(item)
        reload()
        successMessage = "Item updated successfully."
    }

    func deleteItem(_ item: LostFoundItem) {
        repository.deleteItem(item.id)
        reload()
        successMessage = "Item deleted."
    }

    // MARK: Claims

    func submitClaim(
        item: LostFoundItem,
        verification: String
    ) -> Bool {

        guard let user = currentUser else {
            return false
        }

        guard !verification.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please provide ownership verification."
            return false
        }

        let alreadyClaimed = allClaims.contains {
            $0.itemID == item.id &&
            $0.studentID == user.id &&
            $0.status == .pending
        }

        if alreadyClaimed {
            errorMessage = "You already have a pending claim for this item."
            return false
        }

        let claim = Claim(
            itemID: item.id,
            studentID: user.id,
            verificationInformation: verification
        )

        repository.saveClaim(claim)
        reload()

        addNotification(
            userID: user.id,
            title: "Claim Submitted",
            message: "Your claim is pending verification."
        )

        successMessage = "Claim submitted successfully."

        return true
    }

    func approveReport(_ item: LostFoundItem) {
        var updated = item
        updated.status = .approved

        repository.updateItem(updated)
        reload()

        addNotification(
            userID: item.userID,
            title: "Report Approved",
            message: "\(item.itemName) has been approved."
        )
    }

    func rejectReport(_ item: LostFoundItem) {
        var updated = item
        updated.status = .rejected

        repository.updateItem(updated)
        reload()

        addNotification(
            userID: item.userID,
            title: "Report Rejected",
            message: "\(item.itemName) was rejected during verification."
        )
    }

    func approveClaim(_ claim: Claim) {
        var updatedClaim = claim
        updatedClaim.status = .approved

        repository.updateClaim(updatedClaim)

        if var item = allItems.first(where: {
            $0.id == claim.itemID
        }) {
            item.status = .claimed
            repository.updateItem(item)
        }

        reload()

        addNotification(
            userID: claim.studentID,
            title: "Claim Approved",
            message: "Your claim has been approved. The item is now marked as claimed."
        )
    }

    func rejectClaim(_ claim: Claim) {
        var updatedClaim = claim
        updatedClaim.status = .rejected

        repository.updateClaim(updatedClaim)
        reload()

        addNotification(
            userID: claim.studentID,
            title: "Claim Rejected",
            message: "Your claim was rejected during verification."
        )
    }

    func updateItemStatus(
        _ item: LostFoundItem,
        status: ItemStatus
    ) {
        var updated = item
        updated.status = status

        repository.updateItem(updated)
        reload()

        addNotification(
            userID: item.userID,
            title: "Item Status Updated",
            message: "\(item.itemName) is now \(status.rawValue)."
        )
    }

    // MARK: Notifications

    private func addNotification(
        userID: UUID,
        title: String,
        message: String
    ) {
        let notification = NotificationItem(
            userID: userID,
            title: title,
            message: message
        )

        repository.saveNotification(notification)
        reload()
    }

    func markNotificationRead(_ notification: NotificationItem) {
        var updated = notification
        updated.isRead = true

        repository.updateNotification(updated)
        reload()
    }

    func markAllNotificationsRead() {
        guard let userID = currentUser?.id else {
            return
        }

        for notification in allNotifications
        where notification.userID == userID && !notification.isRead {

            var updated = notification
            updated.isRead = true
            repository.updateNotification(updated)
        }

        reload()
    }

    // MARK: Profile

    func updateProfile(
        fullName: String,
        email: String,
        universityID: String
    ) -> Bool {

        guard var user = currentUser else {
            return false
        }

        guard !fullName.isEmpty,
              !email.isEmpty,
              !universityID.isEmpty else {

            errorMessage = "Please complete all profile fields."
            return false
        }

        user.fullName = fullName
        user.email = email
        user.universityID = universityID

        repository.updateUser(user)

        currentUser = user
        reload()

        successMessage = "Profile updated successfully."

        return true
    }

    func changePassword(
        current: String,
        new: String,
        confirm: String
    ) -> Bool {

        guard var user = currentUser else {
            return false
        }

        guard user.password == current else {
            errorMessage = "Current password is incorrect."
            return false
        }

        guard !new.isEmpty else {
            errorMessage = "New password cannot be empty."
            return false
        }

        guard new == confirm else {
            errorMessage = "New passwords do not match."
            return false
        }

        user.password = new

        repository.updateUser(user)

        currentUser = user
        reload()

        successMessage = "Password changed successfully."

        return true
    }

    // MARK: Helpers

    func userName(for id: UUID) -> String {
        allUsers.first(where: { $0.id == id })?.fullName ?? "Unknown User"
    }

    func unreadCount() -> Int {
        guard let userID = currentUser?.id else {
            return 0
        }

        return allNotifications.filter {
            $0.userID == userID && !$0.isRead
        }.count
    }
}