import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: UUID
    var fullName: String
    var email: String
    var password: String
    var universityID: String
    var role: UserRole
    var profilePhotoData: Data?

    init(
        id: UUID = UUID(),
        fullName: String,
        email: String,
        password: String,
        universityID: String,
        role: UserRole,
        profilePhotoData: Data? = nil
    ) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.password = password
        self.universityID = universityID
        self.role = role
        self.profilePhotoData = profilePhotoData
    }

    var initials: String {
        let parts = fullName.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map(String.init)
        return letters.joined().uppercased()
    }
}
