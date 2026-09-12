import Foundation

struct Claim: Identifiable, Codable, Equatable {
    let id: UUID
    var itemID: UUID
    var studentID: UUID
    var appearance: String
    var contents: String
    var context: String
    var verificationInformation: String
    var status: ClaimStatus
    let createdAt: Date

    init(
        id: UUID = UUID(),
        itemID: UUID,
        studentID: UUID,
        appearance: String = "",
        contents: String = "",
        context: String = "",
        verificationInformation: String = "",
        status: ClaimStatus = .pending,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.itemID = itemID
        self.studentID = studentID
        self.appearance = appearance
        self.contents = contents
        self.context = context
        let combined = [appearance, contents, context, verificationInformation]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
        self.verificationInformation = verificationInformation.isEmpty ? combined : verificationInformation
        self.status = status
        self.createdAt = createdAt
    }
}
