import Foundation

// Form values only; all data operations and business rules stay in AppController.
struct ItemDraft {
    var name = ""
    var category: ItemCategory = .ids
    var customCategory = ""
    var location = "Main Library"
    var date = Date()
    var description = ""
    var type: ItemType = .lost
    var photoData: Data?
}

