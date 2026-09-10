import SwiftUI
import UIKit

struct ItemPhoto: View {
    let data: Data?
    var body: some View {
        if let data, let photo = UIImage(data: data) {
            Image(uiImage: photo).resizable().scaledToFit()
        } else {
            ZStack {
                AppColors.accentMuted
                Image(systemName: "shippingbox.fill").font(.largeTitle).foregroundStyle(AppColors.accent)
            }
        }
    }
}

