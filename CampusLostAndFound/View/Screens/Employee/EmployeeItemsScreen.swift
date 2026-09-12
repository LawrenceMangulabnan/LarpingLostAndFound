import SwiftUI

struct EmployeeItemsScreen: View {
    @EnvironmentObject private var app: AppController
    @State private var search = ""
    @State private var type = "all"
    @State private var pending: (LostFoundItem, ItemStatus)?
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Item Management").font(.system(size: 22, weight: .bold)).foregroundStyle(AppColors.label)
                SearchBar(text: $search, placeholder: "Search all items…")
                CapsuleSegment(options: [("all", "All"), ("lost", "Lost"), ("found", "Found")], value: $type)
                Text("\(filtered.count) items").font(.system(size: 13, weight: .medium)).foregroundStyle(AppColors.label3)
                ForEach(filtered) { item in
                    VStack(spacing: 0) {
                        NavigationLink { EmployeeItemStatusScreen(item: item) } label: {
                            HStack(alignment: .top, spacing: 12) {
                                ItemPhoto(item: item).frame(width: 80, height: 80).clipShape(RoundedRectangle(cornerRadius: 12))
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack { Text(item.itemName).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.label).lineLimit(1); Spacer(); StatusBadge(text: item.status.rawValue) }
                                    Text("\(item.displayCategory) · \(item.type.rawValue)").font(.system(size: 12)).foregroundStyle(AppColors.label3)
                                    Text("\(item.building) · \(item.date.formatted(date: .abbreviated, time: .omitted))").font(.system(size: 12)).foregroundStyle(AppColors.label3)
                                }
                            }.padding(12)
                        }.buttonStyle(.plain)
                        Divider().background(AppColors.sep).padding(.horizontal, 12)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach([ItemStatus.approved, .claimed, .returned, .rejected, .archived]) { status in
                                    Button {
                                        pending = (item, status)
                                    } label: {
                                        Text(label(status)).font(.system(size: 12, weight: .semibold)).foregroundStyle(StatusStyle.style(for: status.rawValue).text)
                                            .padding(.horizontal, 12).padding(.vertical, 6)
                                            .background(StatusStyle.style(for: status.rawValue).bg).clipShape(Capsule())
                                    }.buttonStyle(.plain)
                                }
                            }.padding(12)
                        }
                    }.background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }.padding(16)
        }
        .background(AppColors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("Update Item Status?", isPresented: Binding(get: { pending != nil }, set: { if !$0 { pending = nil } }), titleVisibility: .visible) {
            Button("Update Status") {
                if let pending { app.updateItemStatus(pending.0, to: pending.1) }
                self.pending = nil
            }
            Button("Cancel", role: .cancel) { pending = nil }
        } message: {
            Text("Change status to \"\(pending?.1.rawValue ?? "")\"?")
        }
    }

    private var filtered: [LostFoundItem] {
        app.items.filter { type == "all" || $0.type.rawValue.lowercased() == type }
            .filter { search.isEmpty || $0.itemName.localizedCaseInsensitiveContains(search) }
            .sorted { $0.createdAt > $1.createdAt }
    }
    private func label(_ status: ItemStatus) -> String {
        switch status {
        case .approved: return "Approve"
        case .claimed: return "Claim"
        case .returned: return "Return"
        case .rejected: return "Reject"
        case .archived: return "Archive"
        default: return status.rawValue
        }
    }
}
