import SwiftUI

struct StatusBadge: View {
    let text: String
    var body: some View {
        Text(text).font(.caption.bold())
            .foregroundStyle(text.contains("Approved") || text == "Returned" ? AppColors.success : AppColors.accent)
            .padding(8).background(AppColors.elevated).clipShape(Capsule())
    }
}
