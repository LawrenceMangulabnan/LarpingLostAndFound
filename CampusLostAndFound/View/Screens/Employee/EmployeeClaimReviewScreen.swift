import SwiftUI

struct EmployeeClaimReviewScreen: View {
    @EnvironmentObject private var app: AppController
    let claim: Claim
    @State private var reason = ""
    @State private var approveAsk = false
    @State private var rejectAsk = false
    var body: some View {
        ScrollView {
            if let live = app.claims.first(where: { $0.id == claim.id }) {
                VStack(alignment: .leading, spacing: 16) {
                    if let item = app.items.first(where: { $0.id == live.itemID }) {
                        ItemPhoto(item: item).frame(height: 180).clipShape(RoundedRectangle(cornerRadius: 16))
                        Text(item.itemName).font(.title.bold()).foregroundStyle(AppColors.label)
                    }
                    Text("Claimant: \(app.userName(for: live.studentID))").foregroundStyle(AppColors.label)
                    StatusBadge(text: live.status.shortLabel)
                    Text(live.createdAt.formatted()).foregroundStyle(AppColors.label3)
                    group("Appearance", live.appearance)
                    group("Contents", live.contents.isEmpty ? live.verificationInformation : live.contents)
                    group("Context", live.context)
                    if live.status == .pending {
                        AppButton(title: "Approve Claim") { approveAsk = true }
                        TextField("Optional rejection reason", text: $reason, axis: .vertical).padding().background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 12))
                        Button("Reject Claim", role: .destructive) { rejectAsk = true }.frame(maxWidth: .infinity).padding().background(AppColors.redLight).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }.padding(16)
            } else { ContentUnavailableView("Claim no longer available", systemImage: "tray") }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Review Claim")
        .confirmationDialog("Approve this claim?", isPresented: $approveAsk, titleVisibility: .visible) {
            Button("Approve Claim") { app.approveClaim(claim) }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Reject this claim?", isPresented: $rejectAsk, titleVisibility: .visible) {
            Button("Reject Claim", role: .destructive) { app.rejectClaim(claim, reason: reason) }
            Button("Cancel", role: .cancel) {}
        }
    }
    private func group(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundStyle(AppColors.label3)
            Text(value.isEmpty ? "—" : value).foregroundStyle(AppColors.label2)
        }.padding().frame(maxWidth: .infinity, alignment: .leading).background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
