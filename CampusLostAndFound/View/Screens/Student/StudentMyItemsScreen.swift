import SwiftUI

struct StudentMyItemsScreen: View {
    @EnvironmentObject private var app: AppController
    @State private var tab = "lost"
    @State private var deleteItem: LostFoundItem?
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("My Reports").font(.system(size: 22, weight: .bold)).foregroundStyle(AppColors.label)
                    Spacer()
                    Text(app.currentUser?.initials ?? "A").font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                        .frame(width: 36, height: 36).background(AppColors.red).clipShape(Circle())
                }
                if let user = app.currentUser {
                    HStack(spacing: 8) {
                        pill("\(userLost(user).count) Lost", AppColors.redLight, AppColors.red)
                        pill("\(userFound(user).count) Found", AppColors.greenLight, AppColors.green)
                        pill("\(app.claims(for: user.id).count) Claims", AppColors.orangeLight, AppColors.orange)
                    }
                    CapsuleSegment(options: [("lost", "Lost Items"), ("found", "Found Items"), ("claims", "Claims")], value: $tab)
                    if tab == "claims" {
                        claimsList(user)
                    } else {
                        let list = tab == "lost" ? userLost(user) : userFound(user)
                        if list.isEmpty {
                            EmptyState(emoji: tab == "lost" ? "🔍" : "✋", title: "No \(tab) items", button: "Report an Item") {
                                app.openReport(tab == "lost" ? .lost : .found)
                            }
                        } else {
                            VStack(spacing: 12) {
                                ForEach(list) { item in
                                    VStack(spacing: 0) {
                                        HStack(spacing: 12) {
                                            ItemPhoto(item: item).frame(width: 68, height: 68).clipShape(RoundedRectangle(cornerRadius: 12))
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack {
                                                    Text(item.itemName).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.label).lineLimit(1)
                                                    Spacer()
                                                    StatusBadge(text: app.visualStatusLabel(for: item))
                                                }
                                                Text(item.building).font(.system(size: 12)).foregroundStyle(AppColors.label3)
                                                Text(item.date.formatted(date: .abbreviated, time: .omitted)).font(.system(size: 12)).foregroundStyle(AppColors.label3)
                                            }
                                        }.padding(12)
                                        Divider().background(AppColors.sep).padding(.horizontal, 12)
                                        HStack(spacing: 8) {
                                            NavigationLink { StudentItemDetailScreen(item: item) } label: { mini("View", AppColors.blueLight, AppColors.blue) }
                                            NavigationLink { EditItemScreen(item: item) } label: { mini("Edit", AppColors.cardHi, AppColors.label) }
                                            Button { deleteItem = item } label: { mini("Delete", AppColors.redLight, AppColors.red) }.buttonStyle(.plain)
                                        }.padding(12)
                                    }
                                    .background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(AppColors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("Delete this report?", isPresented: Binding(get: { deleteItem != nil }, set: { if !$0 { deleteItem = nil } }), titleVisibility: .visible) {
            Button("Delete Report", role: .destructive) {
                if let deleteItem { _ = app.deleteItem(deleteItem) }
                self.deleteItem = nil
            }
            Button("Cancel", role: .cancel) { deleteItem = nil }
        } message: {
            Text("This will permanently remove your report and all associated claims.")
        }
    }

    private func userLost(_ user: User) -> [LostFoundItem] { app.items.filter { $0.userID == user.id && $0.type == .lost }.sorted { $0.createdAt > $1.createdAt } }
    private func userFound(_ user: User) -> [LostFoundItem] { app.items.filter { $0.userID == user.id && $0.type == .found }.sorted { $0.createdAt > $1.createdAt } }

    @ViewBuilder private func claimsList(_ user: User) -> some View {
        let list = app.claims(for: user.id)
        if list.isEmpty {
            EmptyState(emoji: "📋", title: "No claims yet", button: "Browse Items") { app.openStudent(.browse) }
        } else {
            VStack(spacing: 12) {
                ForEach(list) { claim in
                    let item = app.items.first { $0.id == claim.itemID }
                    NavigationLink { if let item { StudentItemDetailScreen(item: item) } } label: {
                        HStack(spacing: 12) {
                            if let item { ItemPhoto(item: item).frame(width: 56, height: 56).clipShape(RoundedRectangle(cornerRadius: 10)) }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(app.itemName(for: claim.itemID)).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.label)
                                Text("Submitted \(claim.createdAt.formatted(date: .abbreviated, time: .omitted))").font(.system(size: 12)).foregroundStyle(AppColors.label3)
                                StatusBadge(text: claim.status.shortLabel)
                            }
                            Spacer()
                        }.padding(12).background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 16))
                    }.buttonStyle(.plain)
                }
            }
        }
    }

    private func pill(_ text: String, _ bg: Color, _ fg: Color) -> some View {
        Text(text).font(.system(size: 12, weight: .semibold)).foregroundStyle(fg).padding(.horizontal, 10).padding(.vertical, 4).background(bg).clipShape(Capsule())
    }
    private func mini(_ title: String, _ bg: Color, _ fg: Color) -> some View {
        Text(title).font(.system(size: 13, weight: .semibold)).foregroundStyle(fg).frame(maxWidth: .infinity).padding(.vertical, 8).background(bg).clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
