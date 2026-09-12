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
    @Published var studentTab: StudentTab = .home
    @Published var employeeTab: EmployeeTab = .dashboard
    @Published var reportPrefillType: ItemType = .lost
    @Published var browseCategory: ItemCategory?
    @Published var browseSearch = ""
    @Published var watchlist: Set<UUID> = []
    @Published var flags: [UUID: String] = [:]
    @Published var itemMatchAlerts = true
    @Published var claimStatusUpdates = true
    @Published var newItemsNearby = false
    @Published var newReportAlerts = true
    @Published var newClaimAlerts = true
    @Published var dailySummary = true
    @Published var lastRating = 0
    @Published var lastRatingFeedback = ""
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
    func succeed(_ message: String) { errorMessage = nil; successMessage = message }
    private func notify(_ id: UUID, _ title: String, _ message: String, itemID: UUID? = nil) {
        repository.saveNotification(AppNotification(userID: id, title: title, message: message, relatedItemID: itemID))
        reload()
    }
    private func notifyEmployees(_ title: String, _ message: String, itemID: UUID? = nil) {
        for user in users where user.role == .employee { notify(user.id, title, message, itemID: itemID) }
    }
    private func employee() -> Bool {
        guard currentUser?.role == .employee else { return fail("Employee access required.") }
        return true
    }

    func openReport(_ type: ItemType) { reportPrefillType = type; studentTab = .report }
    func openBrowse(category: ItemCategory? = nil, search: String = "") {
        browseCategory = category; browseSearch = search; studentTab = .browse
    }
    func openStudent(_ tab: StudentTab) { studentTab = tab }
    func openEmployee(_ tab: EmployeeTab) { employeeTab = tab }

    func login(email: String, password: String, role: UserRole) -> Bool {
        guard !clean(email).isEmpty, !password.isEmpty else { return fail("Please fill in all fields.") }
        errorMessage = nil; successMessage = nil
        if users.contains(where: { $0.email.lowercased() == clean(email).lowercased() }),
           !users.contains(where: { $0.email.lowercased() == clean(email).lowercased() && $0.password == password && $0.role == role }) {
            return fail("Incorrect password or role for this account.")
        }
        if let user = users.first(where: { $0.email.lowercased() == clean(email).lowercased() && $0.password == password && $0.role == role }) {
            currentUser = user
        } else {
            let user = User(fullName: role == .student ? "Alex Jordan" : "Jamie Rivera", email: clean(email), password: password, universityID: role == .student ? "2024-DEMO" : "EMP-DEMO", role: role)
            repository.saveUser(user); reload(); currentUser = user
        }
        studentTab = .home; employeeTab = .dashboard
        return true
    }

    func signup(fullName: String, email: String, password: String, universityID: String, confirmPassword: String = "", role: UserRole = .student) -> Bool {
        let emailOK = clean(email).contains("@") && clean(email).contains(".")
        guard clean(fullName).count > 1, clean(universityID).count > 2, emailOK else { return fail("Complete all fields with a valid email.") }
        if !confirmPassword.isEmpty {
            guard password.count >= 8, password.rangeOfCharacter(from: .uppercaseLetters) != nil, password.rangeOfCharacter(from: .decimalDigits) != nil else {
                return fail("Min 8 chars, 1 uppercase, 1 number.")
            }
            guard password == confirmPassword else { return fail("Passwords do not match.") }
        } else {
            guard password.count >= 6 else { return fail("Complete all fields with a valid email and a password of at least 6 characters.") }
        }
        guard !users.contains(where: { $0.email.lowercased() == clean(email).lowercased() }) else { return fail("That email is already registered.") }
        let user = User(fullName: clean(fullName), email: clean(email), password: password, universityID: clean(universityID), role: role)
        repository.saveUser(user); reload(); succeed("Account created."); return true
    }

    func logout() {
        currentUser = nil; errorMessage = nil; successMessage = nil
        studentTab = .home; employeeTab = .dashboard
    }

    func resetPassword(email: String) -> Bool {
        guard clean(email).contains("@") else { return fail("Enter a valid email.") }
        succeed("Reset instructions simulated for \(clean(email)).")
        return true
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
        repository.saveItem(item); reload()
        notifyEmployees("New Report", "\(item.itemName) needs verification.", itemID: item.id)
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
        updated.photoData = item.photoData ?? stored.photoData
        if stored.status == .approved || stored.status == .rejected { updated.status = .pending }
        repository.updateItem(updated); reload()
        if updated.status == .pending { notifyEmployees("Report Updated", "\(item.itemName) needs verification.", itemID: updated.id) }
        succeed("Report saved."); return true
    }

    @discardableResult func deleteItem(_ item: LostFoundItem) -> Bool {
        guard let stored = items.first(where: { $0.id == item.id }), stored.userID == currentUser?.id else { return fail("You can only delete your own reports.") }
        guard ![ItemStatus.claimed, .returned, .archived].contains(stored.status) else { return fail("Completed reports cannot be deleted. Contact staff for assistance.") }
        for claim in claims where claim.itemID == stored.id {
            notify(claim.studentID, "Report Deleted", "The reporter deleted \(stored.itemName). Its claims are no longer available.", itemID: stored.id)
        }
        repository.deleteItem(stored.id); reload(); succeed("Report deleted."); return true
    }

    func submitClaim(item: LostFoundItem, verification: String, appearance: String = "", contents: String = "", context: String = "") -> Bool {
        guard let user = currentUser, user.role == .student, let live = items.first(where: { $0.id == item.id }), live.status == .approved, live.userID != user.id else { return fail("This item is not available to claim.") }
        let proof = [clean(verification), clean(appearance), clean(contents)].joined()
        guard !proof.isEmpty else { return fail("Provide proof of ownership.") }
        guard !claims.contains(where: { $0.itemID == item.id && $0.studentID == user.id && $0.status == .pending }) else { return fail("You already have a pending claim for this item.") }
        repository.saveClaim(Claim(itemID: item.id, studentID: user.id, appearance: clean(appearance), contents: clean(contents), context: clean(context), verificationInformation: clean(verification).isEmpty ? proof : clean(verification)))
        reload()
        notifyEmployees("New Claim", "\(item.itemName) has a claim to review.", itemID: item.id)
        notify(live.userID, "New Claim Received", "A claim has been submitted for \(live.itemName).", itemID: live.id)
        succeed("Claim submitted. Status: Pending Verification."); return true
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
        notify(live.userID, "Report \(status.rawValue)", "Your \(live.type.rawValue.lowercased()) item report for '\(live.itemName)' was \(status.rawValue.lowercased()). \(clean(reason))", itemID: live.id)
        succeed("Report \(status.rawValue.lowercased()).")
    }

    func approveClaim(_ claim: Claim) {
        guard employee(), var live = claims.first(where: { $0.id == claim.id }), live.status == .pending else { return }
        guard var item = items.first(where: { $0.id == live.itemID }), item.status == .approved else { fail("The item must be approved before approving a claim."); return }
        live.status = .approved; item.status = .claimed
        repository.updateClaim(live); repository.updateItem(item); reload()
        notify(live.studentID, "Claim Approved", "Your claim for \(item.itemName) was approved. Visit the Lost & Found office to collect your item.", itemID: item.id)
        for other in claims where other.itemID == item.id && other.status == .pending {
            rejectClaim(other, reason: "Another ownership claim was approved.")
        }
        succeed("Claim approved. Item marked as Claimed.")
    }

    func rejectClaim(_ claim: Claim, reason: String) {
        guard employee(), var live = claims.first(where: { $0.id == claim.id }), live.status == .pending else { return }
        live.status = .rejected; repository.updateClaim(live); reload()
        notify(live.studentID, "Claim Rejected", "\(itemName(for: live.itemID)). \(clean(reason))", itemID: live.itemID)
        succeed("Claim rejected.")
    }

    func updateItemStatus(_ item: LostFoundItem, to status: ItemStatus) {
        guard employee(), var live = items.first(where: { $0.id == item.id }) else { return }
        guard live.status != status else { return }
        if [.pending, .approved, .rejected].contains(status) {
            for var claim in claims where claim.itemID == item.id && claim.status == .approved {
                claim.status = .rejected
                repository.updateClaim(claim)
                notify(claim.studentID, "Claim Approval Revoked", "Staff changed \(live.itemName) to \(status.rawValue). Contact staff for details.", itemID: live.id)
            }
        }
        live.status = status; repository.updateItem(live); reload()
        if [.rejected, .claimed, .returned, .archived].contains(status) {
            for claim in claims where claim.itemID == item.id && claim.status == .pending {
                rejectClaim(claim, reason: "The item is now \(status.rawValue).")
            }
        }
        if status == .returned {
            for var claim in claims where claim.itemID == item.id && claim.status == .approved {
                claim.status = .returned
                repository.updateClaim(claim)
            }
            reload()
        }
        notify(live.userID, "Item Status Updated", "\(live.itemName) is now \(status.rawValue).", itemID: live.id)
        succeed("Status updated to \(status.rawValue).")
    }

    func archiveItem(_ item: LostFoundItem) { updateItemStatus(item, to: .archived) }

    func markNotificationRead(_ notification: AppNotification) {
        guard var live = notifications.first(where: { $0.id == notification.id }), live.userID == currentUser?.id else { return }
        live.isRead = true; repository.updateNotification(live); reload()
    }
    func markAllNotificationsRead() {
        for notification in notifications where notification.userID == currentUser?.id && !notification.isRead { markNotificationRead(notification) }
    }

    func updateProfile(fullName: String, universityID: String, email: String? = nil, photoData: Data? = nil) -> Bool {
        guard var user = currentUser else { return fail("Sign in first.") }
        guard !clean(fullName).isEmpty, !clean(universityID).isEmpty else { return fail("Complete all profile fields.") }
        user.fullName = clean(fullName); user.universityID = clean(universityID)
        if let email, !clean(email).isEmpty { user.email = clean(email) }
        if let photoData { user.profilePhotoData = photoData }
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

    func toggleWatchlist(_ item: LostFoundItem) {
        if watchlist.contains(item.id) { watchlist.remove(item.id) } else { watchlist.insert(item.id) }
    }
    func flagItem(_ item: LostFoundItem, reason: String) {
        flags[item.id] = clean(reason).isEmpty ? "Flagged as inappropriate" : clean(reason)
        notifyEmployees("Item Flagged", "\(item.itemName) was flagged for review.", itemID: item.id)
        succeed("Report submitted. Staff will review this item.")
    }
    func submitRating(stars: Int, feedback: String) {
        lastRating = stars; lastRatingFeedback = clean(feedback)
    }
    func copyItemLink(_ item: LostFoundItem) -> String { "campuslostfound://item/\(item.id.uuidString)" }

    func userName(for id: UUID) -> String { users.first(where: { $0.id == id })?.fullName ?? "Unknown user" }
    func itemName(for id: UUID) -> String { items.first(where: { $0.id == id })?.itemName ?? "Deleted item" }
    func claims(for id: UUID) -> [Claim] { self.claims.filter { $0.studentID == id }.sorted { $0.createdAt > $1.createdAt } }
    func notifications(for id: UUID) -> [AppNotification] { self.notifications.filter { $0.userID == id }.sorted { $0.createdAt > $1.createdAt } }
    func unreadCount(for id: UUID) -> Int { notifications(for: id).filter { !$0.isRead }.count }
    func pendingClaimCount(for item: LostFoundItem) -> Int { claims.filter { $0.itemID == item.id && $0.status == .pending }.count }
    func visualStatus(for item: LostFoundItem) -> ItemStatus {
        if item.status == .approved && pendingClaimCount(for: item) > 0 { return .pending }
        return item.status
    }
    func visualStatusLabel(for item: LostFoundItem) -> String {
        if item.status == .approved && pendingClaimCount(for: item) > 0 { return "Claim Pending" }
        return item.status.rawValue
    }
}
