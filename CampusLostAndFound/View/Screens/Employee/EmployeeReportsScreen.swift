import SwiftUI

struct EmployeeReportsScreen: View {
    @EnvironmentObject private var app: AppController
    @State private var tab = "pending"
    @State private var confirm: (LostFoundItem, String)?
    @State private var reason = ""
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Manage Reports").font(.system(size: 22, weight: .bold)).foregroundStyle(AppColors.label)
                CapsuleSegment(options: [("pending", "Pending (\(app.items.filter { $0.status == .pending }.count))"), ("approved", "Approved"), ("rejected", "Rejected")], value: $tab)
                let list = app.items.filter { $0.status.rawValue.lowercased().contains(tab) || ($0.status == .pending && tab == "pending") || ($0.status == .approved && tab == "approved") || ($0.status == .rejected && tab == "rejected") }.sorted { $0.createdAt > $1.createdAt }
                if list.isEmpty {
                    EmptyState(emoji: tab == "pending" ? "⏳" : tab == "approved" ? "✅" : "❌", title: "No \(tab) reports")
                } else {
                    ForEach(list) { item in
                        VStack(spacing: 0) {
                            HStack(alignment: .top, spacing: 12) {
                                ItemPhoto(item: item).frame(width: 80, height: 80).clipShape(RoundedRectangle(cornerRadius: 12))
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack { Text(item.itemName).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.label).lineLimit(1); Spacer(); StatusBadge(text: item.status.rawValue) }
                                    Text("Reporter: \(app.userName(for: item.userID))").font(.system(size: 12)).foregroundStyle(AppColors.label3)
                                    Text("\(item.displayCategory) · \(item.building)").font(.system(size: 12)).foregroundStyle(AppColors.label3)
                                    Text(item.date.formatted(date: .abbreviated, time: .omitted)).font(.system(size: 12)).foregroundStyle(AppColors.label3)
                                }
                            }.padding(12)
                            if tab == "pending" {
                                Divider().background(AppColors.sep).padding(.horizontal, 12)
                                HStack(spacing: 8) {
                                    NavigationLink { EmployeeReportReviewScreen(item: item) } label: { mini("View", AppColors.cardHi, AppColors.label) }
                                    Button { confirm = (item, "approve") } label: { mini("✓ Approve", AppColors.greenLight, AppColors.green) }
                                    Button { confirm = (item, "reject"); reason = "" } label: { mini("✗ Reject", AppColors.redLight, AppColors.red) }
                                }.padding(12)
                            }
                        }.background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }.padding(16)
        }
        .background(AppColors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: Binding(get: { confirm != nil }, set: { if !$0 { confirm = nil } })) {
            if let pair = confirm {
                NavigationStack {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(pair.1 == "approve" ? "Approve this report?" : "Reject this report?").font(.title2.bold()).foregroundStyle(AppColors.label)
                        Text(pair.1 == "approve" ? "This report will be published and visible to students." : "This report will be marked as rejected.").foregroundStyle(AppColors.label2)
                        if pair.1 == "reject" {
                            TextField("Rejection reason", text: $reason, axis: .vertical).padding().background(AppColors.cardHi).clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        AppButton(title: pair.1 == "approve" ? "Approve" : "Reject") {
                            if pair.1 == "approve" { app.approveItem(pair.0) } else { app.rejectItem(pair.0, reason: reason) }
                            confirm = nil
                        }
                        Button("Cancel") { confirm = nil }.foregroundStyle(AppColors.red).frame(maxWidth: .infinity)
                        Spacer()
                    }.padding().background(AppColors.background)
                    .navigationTitle("Confirm")
                }.presentationDetents([.medium])
            }
        }
    }
    private func mini(_ title: String, _ bg: Color, _ fg: Color) -> some View {
        Text(title).font(.system(size: 13, weight: .semibold)).foregroundStyle(fg).frame(maxWidth: .infinity).padding(.vertical, 8).background(bg).clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
