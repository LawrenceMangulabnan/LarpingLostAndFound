import SwiftUI

struct StudentBrowseScreen: View {
    @EnvironmentObject private var app: AppController
    @State private var search = ""
    @State private var category: ItemCategory?
    @State private var type: ItemType?
    @State private var sort: BrowseSort = .newest
    private var results: [LostFoundItem] {
        let filtered = app.items.filter {
            $0.status == .approved && (category == nil || $0.category == category) && (type == nil || $0.type == type) &&
            (search.isEmpty || "\($0.itemName) \($0.location) \($0.displayCategory)".localizedCaseInsensitiveContains(search))
        }
        switch sort {
        case .newest: return filtered.sorted { $0.createdAt > $1.createdAt }
        case .oldest: return filtered.sorted { $0.createdAt < $1.createdAt }
        case .nameAZ: return filtered.sorted { $0.itemName.localizedCaseInsensitiveCompare($1.itemName) == .orderedAscending }
        }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Browse").font(.largeTitle.bold())
                SearchBar(text: $search)
                Picker("Category", selection: $category) {
                    Text("All Categories").tag(nil as ItemCategory?)
                    ForEach(ItemCategory.allCases) { Text($0.rawValue).tag(Optional($0)) }
                }
                Picker("Type", selection: $type) {
                    Text("All Types").tag(nil as ItemType?)
                    ForEach(ItemType.allCases) { Text($0.rawValue).tag(Optional($0)) }
                }.pickerStyle(.segmented)
                Picker("Sort", selection: $sort) { ForEach(BrowseSort.allCases) { Text($0.rawValue).tag($0) } }
                ForEach(results) { item in
                    NavigationLink { StudentItemDetailScreen(item: item) } label: { ItemCard(item: item) }.buttonStyle(.plain)
                }
                if results.isEmpty { ContentUnavailableView("No matching items", systemImage: "magnifyingglass") }
            }.padding()
        }.appBackground()
    }
}
