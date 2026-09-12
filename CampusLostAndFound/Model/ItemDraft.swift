import Foundation

struct ItemDraft {
    var name = ""
    var category: ItemCategory?
    var customCategory = ""
    var location = ""
    var date = Date()
    var description = ""
    var type: ItemType = .lost
    var photoData: Data?
}
