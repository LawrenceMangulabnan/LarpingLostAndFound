import Foundation
import Combine

@MainActor
final class AppController: ObservableObject {
    @Published private(set) var currentUser: User?
    @Published private(set) var users: [User] = []
    @Published private(set) var items: [LostFoundItem] = []
    @Published private(set) var claims: [Claim] = []
    @Published private(set) var notifications: [AppNotification] = []
    @Published var errorMessage: String?
    @Published var successMessage: String?
    private let repository: DataRepository

    init(repository: DataRepository) { self.repository = repository; reload() }
    private func reload() {
        users = repository.fetchUsers(); items = repository.fetchItems()
        claims = repository.fetchClaims(); notifications = repository.fetchNotifications()
    }
    private func clean(_ value: String) -> String { value.trimmingCharacters(in: .whitespacesAndNewlines) }
    @discardableResult private func fail(_ message: String) -> Bool {
        successMessage = nil; errorMessage = message; return false
    }
    private func succeed(_ message: String) { errorMessage = nil; successMessage = message }
    private func notify(_ id: UUID, _ title: String, _ message: String) {
        repository.saveNotification(AppNotification(userID: id, title: title, message: message))
        reload()
    }
    private func notifyEmployees(_ title: String, _ message: String) {
        for user in users where user.role == .employee { notify(user.id, title, message) }
    }
    private func employee() -> Bool {
        guard currentUser?.role == .employee else { return fail("Employee access required.") }
        return true
    }
    func login(email: String, password: String, role: UserRole) -> Bool {
        guard !clean(email).isEmpty, !password.isEmpty else { return fail("Enter your email and password.") }
        errorMessage = nil; successMessage = nil
        if users.contains(where: { $0.email.lowercased() == clean(email).lowercased() }),
           !users.contains(where: { $0.email.lowercased() == clean(email).lowercased() && $0.password == password && $0.role == role }) {
            return fail("Incorrect password or role for this account.")
        }
        if let user = users.first(where: { $0.email.lowercased() == clean(email).lowercased() && $0.password == password && $0.role == role }) {
            currentUser = user
        } else {
            // Deliberately permissive, session-only authentication for this academic mock.
            let user = User(fullName: role == .student ? "Mock Student" : "Mock Employee", email: clean(email), password: password, universityID: role == .student ? "STU-DEMO" : "EMP-DEMO", role: role)
            repository.saveUser(user); reload(); currentUser = user
        }
        return true
    }
    func signup(fullName: String, email: String, password: String, universityID: String) -> Bool {
        guard !clean(fullName).isEmpty, !clean(universityID).isEmpty, clean(email).contains("@"), password.count >= 6 else { return fail("Complete all fields with a valid email and a password of at least 6 characters.") }
        guard !users.contains(where: { $0.email.lowercased() == clean(email).lowercased() }) else { return fail("That email is already registered.") }
        let user = User(fullName: clean(fullName), email: clean(email), password: password, universityID: clean(universityID), role: .student)
        repository.saveUser(user); reload(); currentUser = user; succeed("Account created."); return true
    }
    func logout() { currentUser = nil; errorMessage = nil; successMessage = nil }
    func resetPassword(email: String) {
        guard clean(email).contains("@") else { fail("Enter a valid email."); return }
        succeed("Reset instructions simulated for \(clean(email)). This local prototype does not send email or change your password.")
    }
    private func validItem(_ item: LostFoundItem) -> Bool {
        guard !clean(item.itemName).isEmpty, !clean(item.location).isEmpty, !clean(item.description).isEmpty else { return fail("Enter a name, location, and description.") }
        guard item.category != .other || !clean(item.customCategory).isEmpty else { return fail("Enter a custom category.") }
        return true
    }
    func addItem(photoData: Data?, itemName: String, category: ItemCategory, customCategory: String, location: String, date: Date, description: String, type: ItemType) -> Bool {
        guard let user = currentUser, user.role == .student else { return fail("Sign in as a student to report an item.") }
        let item = LostFoundItem(userID: user.id, photoData: photoData, itemName: clean(itemName), category: category, customCategory: clean(customCategory), location: clean(location), date: date, description: clean(description), type: type)
        guard validItem(item) else { return false }
        repository.saveItem(item); reload(); notifyEmployees("New Report", "\(item.itemName) needs verification.")
        succeed("Report submitted. Status: Pending Verification."); return true
    }
    @discardableResult func updateItem(_ item: LostFoundItem) -> Bool {
        guard let stored = items.first(where: { $0.id == item.id }), stored.userID == currentUser?.id else { return fail("You can only edit your own reports.") }
        guard ![ItemStatus.claimed, .returned, .archived].contains(stored.status) else { return fail("Completed reports cannot be edited. Contact staff for corrections.") }
        guard validItem(item) else { return false }
        var updated = stored
        updated.itemName = clean(item.itemName)
        updated.category = item.category
        updated.customCategory = item.category == .other ? clean(item.customCategory) : ""
        updated.location = clean(item.location)
        updated.date = item.date
        updated.description = clean(item.description)
        updated.type = item.type
        if stored.status == .approved || stored.status == .rejected { updated.status = .pending }
        repository.updateItem(updated); reload()
        if updated.status == .pending { notifyEmployees("Report Updated", "\(item.itemName) needs verification.") }
        succeed("Report saved."); return true
    }
    @discardableResult func deleteItem(_ item: LostFoundItem) -> Bool {
        guard let stored = items.first(where: { $0.id == item.id }), stored.userID == currentUser?.id else { return fail("You can only delete your own reports.") }
        guard ![ItemStatus.claimed, .returned, .archived].contains(stored.status) else { return fail("Completed reports cannot be deleted. Contact staff for assistance.") }
        for claim in claims where claim.itemID == stored.id {
            notify(claim.studentID, "Report Deleted", "The reporter deleted \(stored.itemName). Its claims are no longer available.")
        }
        repository.deleteItem(stored.id); reload(); succeed("Report deleted."); return true
    }
    func submitClaim(item: LostFoundItem, verification: String) -> Bool {
        guard let user = currentUser, user.role == .student, let live = items.first(where: { $0.id == item.id }), live.status == .approved, live.userID != user.id else { return fail("This item is not available to claim.") }
        guard !clean(verification).isEmpty else { return fail("Provide proof of ownership.") }
        guard !claims.contains(where: { $0.itemID == item.id && $0.studentID == user.id && $0.status == .pending }) else { return fail("You already have a pending claim for this item.") }
        repository.saveClaim(Claim(itemID: item.id, studentID: user.id, verificationInformation: clean(verification)))
        reload(); notifyEmployees("New Claim", "\(item.itemName) has a claim to review."); succeed("Claim submitted. Status: Pending Verification."); return true
    }
    func approveItem(_ item: LostFoundItem) { reviewItem(item, status: .approved, reason: "") }
    func rejectItem(_ item: LostFoundItem, reason: String) { reviewItem(item, status: .rejected, reason: reason) }
    private func reviewItem(_ item: LostFoundItem, status: ItemStatus, reason: String) {
        guard employee(), var live = items.first(where: { $0.id == item.id }), live.status == .pending else { return }
        live.status = status; repository.updateItem(live); reload()
        if status == .rejected {
            for claim in claims where claim.itemID == live.id && claim.status == .pending {
                rejectClaim(claim, reason: "The report was rejected. \(clean(reason))")
            }
        }
        notify(live.userID, "Report \(status.rawValue)", "\(live.itemName). \(clean(reason))")
        succeed("Report \(status.rawValue.lowercased()).")
    }
    func approveClaim(_ claim: Claim) {
        guard employee(), var live = claims.first(where: { $0.id == claim.id }), live.status == .pending else { return }
        guard var item = items.first(where: { $0.id == live.itemID }), item.status == .approved else { fail("The item must be approved before approving a claim."); return }
        live.status = .approved; item.status = .claimed
        repository.updateClaim(live); repository.updateItem(item); reload()
        notify(live.studentID, "Claim Approved", "Your claim for \(item.itemName) was approved.")
        for other in claims where other.itemID == item.id && other.status == .pending {
            rejectClaim(other, reason: "Another ownership claim was approved.")
        }
        succeed("Claim approved. Item marked as Claimed.")
    }
    func rejectClaim(_ claim: Claim, reason: String) {
        guard employee(), var live = claims.first(where: { $0.id == claim.id }), live.status == .pending else { return }
        live.status = .rejected; repository.updateClaim(live); reload()
        notify(live.studentID, "Claim Rejected", "\(itemName(for: live.itemID)). \(clean(reason))"); succeed("Claim rejected.")
    }
    func updateItemStatus(_ item: LostFoundItem, to status: ItemStatus) {
        guard employee(), var live = items.first(where: { $0.id == item.id }) else { return }
        guard live.status != status else { return }
        // Reopening an item must also revoke its previously approved ownership claim.
        if [.pending, .approved, .rejected].contains(status) {
            for var claim in claims where claim.itemID == item.id && claim.status == .approved {
                claim.status = .rejected
                repository.updateClaim(claim)
                notify(claim.studentID, "Claim Approval Revoked", "Staff changed \(live.itemName) to \(status.rawValue). Contact staff for details.")
            }
        }
        live.status = status; repository.updateItem(live); reload()
        if [.rejected, .claimed, .returned, .archived].contains(status) {
            for claim in claims where claim.itemID == item.id && claim.status == .pending {
                rejectClaim(claim, reason: "The item is now \(status.rawValue).")
            }
        }
        notify(live.userID, "Item Status Updated", "\(live.itemName) is now \(status.rawValue).")
        succeed("Status updated to \(status.rawValue).")
    }
    func markNotificationRead(_ notification: AppNotification) {
        guard var live = notifications.first(where: { $0.id == notification.id }), live.userID == currentUser?.id else { return }
        live.isRead = true; repository.updateNotification(live); reload()
    }
    func markAllNotificationsRead() {
        for notification in notifications where notification.userID == currentUser?.id && !notification.isRead { markNotificationRead(notification) }
    }
    func updateProfile(fullName: String, universityID: String) -> Bool {
        guard var user = currentUser else { return fail("Sign in first.") }
        guard !clean(fullName).isEmpty, !clean(universityID).isEmpty else { return fail("Complete all profile fields.") }
        user.fullName = clean(fullName); user.universityID = clean(universityID)
        repository.updateUser(user); reload(); currentUser = user; succeed("Profile updated."); return true
    }
    func changePassword(currentPassword: String, newPassword: String, confirmPassword: String) -> Bool {
        guard var user = currentUser else { return fail("Sign in first.") }
        guard user.password == currentPassword else { return fail("Current password is incorrect.") }
        guard newPassword.count >= 6 else { return fail("Use at least 6 characters.") }
        guard newPassword == confirmPassword else { return fail("Passwords do not match.") }
        user.password = newPassword; repository.updateUser(user); reload(); currentUser = user
        succeed("Password changed."); return true
    }
    func userName(for id: UUID) -> String { users.first(where: { $0.id == id })?.fullName ?? "Unknown user" }
    func itemName(for id: UUID) -> String { items.first(where: { $0.id == id })?.itemName ?? "Deleted item" }
    func claims(for id: UUID) -> [Claim] { claims.filter { $0.studentID == id }.sorted { $0.createdAt > $1.createdAt } }
    func notifications(for id: UUID) -> [AppNotification] { notifications.filter { $0.userID == id }.sorted { $0.createdAt > $1.createdAt } }
    func unreadCount(for id: UUID) -> Int { notifications(for: id).filter { !$0.isRead }.count }
}
