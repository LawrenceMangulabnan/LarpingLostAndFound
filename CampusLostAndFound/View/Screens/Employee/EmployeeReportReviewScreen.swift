import SwiftUI

struct EmployeeReportReviewScreen: View {
    @EnvironmentObject private var app: AppController
    let item: LostFoundItem
    @State private var reason = ""
    @State private var approveAsk = false
    @State private var rejectAsk = false
    var body: some View {
        ScrollView {
            if let live = app.items.first(where: { $0.id == item.id }) {
                VStack(alignment: .leading, spacing: 16) {
                    ItemPhoto(item: live).frame(height: 220).clipShape(RoundedRectangle(cornerRadius: 18))
                    Text(live.itemName).font(.system(size: 24, weight: .black)).foregroundStyle(AppColors.label)
                    StatusBadge(text: live.status.rawValue)
                    detail("Category", live.displayCategory)
                    detail("Location", live.location)
                    detail("Date", live.date.formatted(date: .abbreviated, time: .omitted))
                    detail("Reporter", app.userName(for: live.userID))
                    Text(live.description).foregroundStyle(AppColors.label2)
                    if live.status == .pending {
                        AppButton(title: "Approve") { approveAsk = true }
                        TextField("Optional rejection reason", text: $reason, axis: .vertical).padding().background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 12))
                        Button("Reject", role: .destructive) { rejectAsk = true }.frame(maxWidth: .infinity).padding().background(AppColors.redLight).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }.padding(16)
            } else { ContentUnavailableView("Report deleted", systemImage: "tray") }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Review Report")
        .confirmationDialog("Approve this report?", isPresented: $approveAsk, titleVisibility: .visible) {
            Button("Approve") { app.approveItem(item) }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Reject this report?", isPresented: $rejectAsk, titleVisibility: .visible) {
            Button("Reject", role: .destructive) { app.rejectItem(item, reason: reason) }
            Button("Cancel", role: .cancel) {}
        }
    }
    private func detail(_ label: String, _ value: String) -> some View {
        HStack { Text(label).foregroundStyle(AppColors.label3); Spacer(); Text(value).foregroundStyle(AppColors.label) }
    }
}
