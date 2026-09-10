import SwiftUI

struct ItemDetails: View {
    @EnvironmentObject private var app: AppController
    let item: LostFoundItem
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ItemPhoto(data: item.photoData).frame(height: 220).clipShape(RoundedRectangle(cornerRadius: 18))
            Text(item.itemName).font(.largeTitle.bold())
            StatusBadge(text: item.status.rawValue)
            LabeledContent("Type", value: item.type.rawValue)
            LabeledContent("Category", value: item.displayCategory)
            LabeledContent("Location", value: item.location)
            LabeledContent("Date", value: item.date.formatted(date: .abbreviated, time: .omitted))
            LabeledContent("Reporter", value: app.userName(for: item.userID))
            Text("Description").font(.headline)
            Text(item.description)
        }
    }
}

