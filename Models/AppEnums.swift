import Foundation

enum UserRole: String, CaseIterable, Codable, Identifiable {
    case student = "Student"
    case employee = "Lost & Found Employee"

    var id: String { rawValue }
}

enum ItemType: String, CaseIterable, Codable, Identifiable {
    case lost = "Lost"
    case found = "Found"

    var id: String { rawValue }
}

enum ItemCategory: String, CaseIterable, Codable, Identifiable {
    case ids = "IDs & Cards"
    case electronics = "Electronics"
    case bags = "Bags"
    case clothing = "Clothing"
    case keys = "Keys"
    case other = "Other"

    var id: String { rawValue }
}

enum ItemStatus: String, CaseIterable, Codable, Identifiable {
    case pending = "Pending Verification"
    case approved = "Approved"
    case rejected = "Rejected"
    case claimed = "Claimed"
    case returned = "Returned"
    case archived = "Archived"

    var id: String { rawValue }
}

enum ClaimStatus: String, CaseIterable, Codable, Identifiable {
    case pending = "Pending Verification"
    case approved = "Claim Approved"
    case rejected = "Claim Rejected"

    var id: String { rawValue }
}

enum BrowseSort: String, CaseIterable, Identifiable {
    case newest = "Newest"
    case oldest = "Oldest"
    case nameAZ = "Name A-Z"
    var id: String { rawValue }
}
