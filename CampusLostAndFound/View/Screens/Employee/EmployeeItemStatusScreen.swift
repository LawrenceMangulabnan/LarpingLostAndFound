import SwiftUI

struct EmployeeItemStatusScreen: View {
    @EnvironmentObject private var app: AppController
    let item: LostFoundItem
    @State private var pending: ItemStatus?
    var body: some View {
        ScrollView {
            if let live = app.items.first(where: { $0.id == item.id }) {
                VStack(alignment: .leading, spacing: 16) {
                    ItemPhoto(item: live).frame(height: 200).clipShape(RoundedRectangle(cornerRadius: 18))
                    Text(live.itemName).font(.largeTitle.bold()).foregroundStyle(AppColors.label)
                    StatusBadge(text: live.status.rawValue)
                    Text(live.description).foregroundStyle(AppColors.label2)
                    Text("Change Status").font(.title2.bold()).foregroundStyle(AppColors.label)
                    ForEach(ItemStatus.allCases) { status in
                        Button { pending = status } label: {
                            HStack {
                                Text(status.rawValue).foregroundStyle(AppColors.label)
                                Spacer()
                                if live.status == status { Image(systemName: "checkmark").foregroundStyle(AppColors.red) }
                            }.padding().background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 12))
                        }.buttonStyle(.plain).disabled(live.status == status)
                    }
                }.padding(16)
            } else { ContentUnavailableView("Item deleted", systemImage: "tray") }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Item Status")
        .confirmationDialog("Update Item Status?", isPresented: Binding(get: { pending != nil }, set: { if !$0 { pending = nil } }), titleVisibility: .visible) {
            Button("Update Status") { if let pending { app.updateItemStatus(item, to: pending) }; self.pending = nil }
            Button("Cancel", role: .cancel) { pending = nil }
        } message: { Text("Change status to \"\(pending?.rawValue ?? "")\"?") }
    }
}
