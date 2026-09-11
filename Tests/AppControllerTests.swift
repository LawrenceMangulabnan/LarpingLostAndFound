import XCTest
@testable import LarpingLostAndFound

final class AppControllerTests: XCTestCase {
    @MainActor func testReportApprovalAcrossSessions() throws {
        let app = AppController(repository: MockRepository())
        XCTAssertTrue(app.login(email: "student@larping.edu", password: "123456", role: .student))
        let studentID = try XCTUnwrap(app.currentUser?.id)
        XCTAssertTrue(app.addItem(photoData: nil, itemName: "Test Bag", category: .bags, customCategory: "", location: "Main Library", date: Date(), description: "Green bag", type: .lost))
        let report = try XCTUnwrap(app.items.first { $0.itemName == "Test Bag" })
        XCTAssertEqual(report.status, .pending)
        app.logout()
        XCTAssertTrue(app.login(email: "employee@larping.edu", password: "123456", role: .employee))
        XCTAssertTrue(app.notifications(for: try XCTUnwrap(app.currentUser?.id)).contains { $0.title == "New Report" })
        app.approveItem(report)
        XCTAssertEqual(app.items.first { $0.id == report.id }?.status, .approved)
        XCTAssertTrue(app.notifications(for: studentID).contains { $0.title == "Report Approved" })
        app.logout()
        XCTAssertTrue(app.login(email: "student@larping.edu", password: "123456", role: .student))
        XCTAssertEqual(app.items.first { $0.id == report.id }?.status, .approved)
    }

    @MainActor func testClaimsPreventDuplicatesAndResolveCompetingClaims() throws {
        let app = AppController(repository: MockRepository())
        let item = try XCTUnwrap(app.items.first { $0.itemName == "AirPods Case" })
        XCTAssertTrue(app.login(email: "student@larping.edu", password: "123456", role: .student))
        XCTAssertTrue(app.submitClaim(item: item, verification: "Serial number ABC"))
        XCTAssertFalse(app.submitClaim(item: item, verification: "Duplicate"))
        let first = try XCTUnwrap(app.claims.first)
        app.logout()
        XCTAssertTrue(app.login(email: "other@larping.edu", password: "123456", role: .student))
        XCTAssertTrue(app.submitClaim(item: item, verification: "Unique mark"))
        app.logout()
        XCTAssertTrue(app.login(email: "employee@larping.edu", password: "123456", role: .employee))
        app.approveClaim(first)
        XCTAssertEqual(app.claims.first { $0.id == first.id }?.status, .approved)
        XCTAssertEqual(app.claims.filter { $0.status == .rejected }.count, 1)
        XCTAssertEqual(app.items.first { $0.id == item.id }?.status, .claimed)
        app.updateItemStatus(item, to: .approved)
        XCTAssertFalse(app.claims.contains { $0.status == .approved })
    }

    @MainActor func testOwnershipValidationAndDeletionCascade() throws {
        let app = AppController(repository: MockRepository())
        XCTAssertTrue(app.login(email: "student@larping.edu", password: "123456", role: .student))
        let own = try XCTUnwrap(app.items.first { $0.itemName == "Black Wallet" })
        let other = try XCTUnwrap(app.items.first { $0.itemName == "AirPods Case" })
        XCTAssertFalse(app.deleteItem(other))
        XCTAssertFalse(app.updateItem(other))
        app.approveItem(own)
        XCTAssertEqual(app.items.first { $0.id == own.id }?.status, .pending)
        XCTAssertFalse(app.submitClaim(item: own, verification: "Mine"))
        var edited = own
        edited.itemName = "  Updated Wallet  "
        XCTAssertTrue(app.updateItem(edited))
        XCTAssertEqual(app.items.first { $0.id == own.id }?.itemName, "Updated Wallet")
        XCTAssertEqual(app.items.first { $0.id == own.id }?.status, .pending)
        app.logout()
        XCTAssertTrue(app.login(email: "employee@larping.edu", password: "123456", role: .employee))
        app.approveItem(own)
        app.logout()
        XCTAssertTrue(app.login(email: "claimant@larping.edu", password: "123456", role: .student))
        XCTAssertTrue(app.submitClaim(item: own, verification: "Red card inside"))
        app.logout()
        XCTAssertTrue(app.login(email: "student@larping.edu", password: "123456", role: .student))
        XCTAssertTrue(app.deleteItem(own))
        XCTAssertFalse(app.items.contains { $0.id == own.id })
        XCTAssertFalse(app.claims.contains { $0.itemID == own.id })
        XCTAssertFalse(app.submitClaim(item: own, verification: "Stale report"))
    }

    @MainActor func testPasswordChangeAndProfilePersistThroughLogout() throws {
        let app = AppController(repository: MockRepository())
        XCTAssertTrue(app.login(email: "student@larping.edu", password: "123456", role: .student))
        let id = try XCTUnwrap(app.currentUser?.id)
        XCTAssertFalse(app.changePassword(currentPassword: "bad", newPassword: "abcdef", confirmPassword: "abcdef"))
        XCTAssertTrue(app.changePassword(currentPassword: "123456", newPassword: "abcdef", confirmPassword: "abcdef"))
        XCTAssertTrue(app.updateProfile(fullName: "Updated Student", universityID: "STU-2"))
        app.logout()
        let count = app.users.count
        XCTAssertFalse(app.login(email: "student@larping.edu", password: "123456", role: .student))
        XCTAssertEqual(app.users.count, count)
        XCTAssertTrue(app.login(email: "student@larping.edu", password: "abcdef", role: .student))
        XCTAssertEqual(app.currentUser?.id, id)
        XCTAssertEqual(app.currentUser?.fullName, "Updated Student")
    }

    @MainActor func testInvalidReportsAndNotificationIsolation() throws {
        let app = AppController(repository: MockRepository())
        XCTAssertTrue(app.login(email: "student@larping.edu", password: "123456", role: .student))
        let count = app.items.count
        XCTAssertFalse(app.addItem(photoData: nil, itemName: "  ", category: .other, customCategory: "", location: "", date: Date(), description: "", type: .lost))
        XCTAssertEqual(app.items.count, count)
        XCTAssertTrue(app.addItem(photoData: nil, itemName: "Keys", category: .keys, customCategory: "", location: "Main Gate", date: Date(), description: "Two keys", type: .found))
        let employeeNotification = try XCTUnwrap(app.notifications.first)
        app.markNotificationRead(employeeNotification)
        XCTAssertFalse(try XCTUnwrap(app.notifications.first).isRead)
        app.logout()
        XCTAssertTrue(app.login(email: "employee@larping.edu", password: "123456", role: .employee))
        app.markAllNotificationsRead()
        XCTAssertEqual(app.unreadCount(for: try XCTUnwrap(app.currentUser?.id)), 0)
    }
}
