import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search name, location, category", text: $text)
            if !text.isEmpty {
                Button("Clear", systemImage: "xmark.circle.fill") { text = "" }.labelStyle(.iconOnly)
            }
        }.padding().background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
