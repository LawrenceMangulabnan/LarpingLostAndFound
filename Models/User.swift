import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: UUID
    var fullName: String
    var email: String
    var password: String
    var universityID: String
    var role: UserRole

    init(
        id: UUID = UUID(),
        fullName: String,
        email: String,
        password: String,
        universityID: String,
        role: UserRole
    ) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.password = password
        self.universityID = universityID
        self.role = role
    }
}