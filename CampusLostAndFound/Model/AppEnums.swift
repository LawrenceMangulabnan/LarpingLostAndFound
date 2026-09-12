import Foundation

enum UserRole: String, CaseIterable, Codable, Identifiable {
    case student = "Student"
    case employee = "Lost & Found Employee"
    var id: String { rawValue }
    var shortLabel: String { self == .student ? "Student" : "L&F Employee" }
    var emoji: String { self == .student ? "📚" : "🏢" }
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
    var emoji: String {
        switch self {
        case .ids: return "🪪"
        case .electronics: return "📱"
        case .bags: return "🎒"
        case .clothing: return "👕"
        case .keys: return "🔑"
        case .other: return "📦"
        }
    }
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
    case approved = "Approved"
    case rejected = "Rejected"
    case returned = "Returned"
    var id: String { rawValue }
    var shortLabel: String {
        switch self {
        case .pending: return "Pending"
        case .approved: return "Approved"
        case .rejected: return "Rejected"
        case .returned: return "Returned"
        }
    }
}

enum BrowseSort: String, CaseIterable, Identifiable {
    case newest = "Newest"
    case oldest = "Oldest"
    case nameAZ = "Name A-Z"
    var id: String { rawValue }
}

enum StudentTab: Hashable {
    case home, browse, report, myItems, profile
}

enum EmployeeTab: Hashable {
    case dashboard, reports, claims, items, profile
}
