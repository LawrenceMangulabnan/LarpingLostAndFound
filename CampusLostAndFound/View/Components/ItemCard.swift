import SwiftUI
import UIKit

struct ItemPhoto: View {
    let item: LostFoundItem
    var body: some View {
        photo
    }

    @ViewBuilder private var photo: some View {
        if let data = item.photoData, let image = UIImage(data: data) {
            Image(uiImage: image).resizable().scaledToFill()
        } else if let url = item.photoURL, let parsed = URL(string: url) {
            AsyncImage(url: parsed) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFill()
                default: placeholder
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            AppColors.cardHi
            Image(systemName: "shippingbox.fill").font(.largeTitle).foregroundStyle(AppColors.red)
        }
    }
}

struct ItemCard: View {
    let item: LostFoundItem
    var statusLabel: String? = nil
    var body: some View {
        HStack(spacing: 0) {
            ItemPhoto(item: item).frame(width: 88, height: 88).clipped()
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(item.itemName).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.label).lineLimit(1)
                    Spacer(minLength: 8)
                    StatusBadge(text: statusLabel ?? item.status.rawValue)
                }
                Text(item.displayCategory).font(.system(size: 12)).foregroundStyle(AppColors.label3)
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse").font(.system(size: 10)).foregroundStyle(AppColors.label3)
                    Text(item.location).font(.system(size: 12)).foregroundStyle(AppColors.label3).lineLimit(1)
                }
                HStack {
                    Text(item.date.formatted(date: .abbreviated, time: .omitted)).font(.system(size: 12)).foregroundStyle(AppColors.label3)
                    if item.isNew {
                        Text("NEW").font(.system(size: 10, weight: .bold)).foregroundStyle(.white)
                            .padding(.horizontal, 6).padding(.vertical, 1).background(AppColors.red).clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.3), radius: 6, y: 1)
    }
}

struct HorizontalItemCard: View {
    let item: LostFoundItem
    var statusLabel: String
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                ItemPhoto(item: item).frame(width: 172, height: 128).clipped()
                LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .center, endPoint: .bottom)
                StatusBadge(text: statusLabel).padding(10)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(item.itemName).font(.system(size: 14, weight: .semibold)).foregroundStyle(AppColors.label).lineLimit(2)
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse").font(.system(size: 9)).foregroundStyle(AppColors.label3)
                    Text(item.building).font(.system(size: 11)).foregroundStyle(AppColors.label3).lineLimit(1)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 12)
        }
        .frame(width: 172)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.4), radius: 10, y: 4)
    }
}
