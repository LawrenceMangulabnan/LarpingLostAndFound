import SwiftUI

struct StatCard: View {
    let title: String
    let value: Int
    let icon: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).foregroundStyle(AppColors.accent)
            Text(value.formatted()).font(.largeTitle.bold())
            Text(title).font(.subheadline)
        }.frame(maxWidth: .infinity, alignment: .leading).appCard()
    }
}
