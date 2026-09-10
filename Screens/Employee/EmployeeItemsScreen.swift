import SwiftUI

struct EmployeeItemsScreen: View {
    @EnvironmentObject private var app: AppController
    @State private var status: ItemStatus?
    init(initialStatus: ItemStatus? = nil) { _status = State(initialValue: initialStatus) }
    private var results: [LostFoundItem] { app.items.filter { status == nil || $0.status == status }.sorted { $0.createdAt > $1.createdAt } }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Items").font(.largeTitle.bold())
                ItemStatusFilter(status: $status)
                ForEach(results) { item in
                    NavigationLink { EmployeeItemStatusScreen(item: item) } label: { ItemCard(item: item) }.buttonStyle(.plain)
                }
                if results.isEmpty { Text("No items for this status.") }
            }.padding()
        }.appBackground()
    }
}

