import SwiftUI

struct EmployeeReportReviewScreen: View {
    @EnvironmentObject private var app: AppController
    let item: LostFoundItem
    @State private var reason = ""
    var body: some View {
        ScrollView {
            if let live = app.items.first(where: { $0.id == item.id }) {
                VStack(alignment: .leading, spacing: 18) {
                    ItemDetails(item: live)
                    if live.status == .pending {
                        AppButton(title: "Approve Report") { app.approveItem(live) }
                        TextField("Optional rejection reason", text: $reason, axis: .vertical).textFieldStyle(.roundedBorder)
                        Button("Reject Report", role: .destructive) { app.rejectItem(live, reason: reason) }.buttonStyle(.bordered)
                    }
                }.padding()
            } else { ContentUnavailableView("Report deleted", systemImage: "tray") }
        }.appBackground().navigationTitle("Review Report").navigationBarTitleDisplayMode(.inline)
    }
}

