import SwiftUI
import UIKit

struct ItemCard: View {
    let item: LostFoundItem
    var body: some View {
        HStack(spacing: 12) {
            ItemPhoto(data: item.photoData).frame(width: 64, height: 64).clipped().clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 6) {
                Text(item.itemName).font(.headline)
                Text("\(item.type.rawValue) · \(item.displayCategory)").font(.caption)
                Text(item.location).font(.caption).foregroundStyle(AppColors.secondaryText)
                StatusBadge(text: item.status.rawValue)
            }
            Spacer(minLength: 0)
        }.frame(maxWidth: .infinity, alignment: .leading).appCard()
    }
}

