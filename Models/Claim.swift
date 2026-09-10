import Foundation

struct Claim: Identifiable, Codable, Equatable {
    let id: UUID
    var itemID: UUID
    var studentID: UUID
    var verificationInformation: String
    var status: ClaimStatus
    let createdAt: Date

    init(
        id: UUID = UUID(),
        itemID: UUID,
        studentID: UUID,
        verificationInformation: String,
        status: ClaimStatus = .pending,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.itemID = itemID
        self.studentID = studentID
        self.verificationInformation = verificationInformation
        self.status = status
        self.createdAt = createdAt
    }
}