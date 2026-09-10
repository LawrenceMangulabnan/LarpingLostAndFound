import SwiftUI

struct EmployeeClaimReviewScreen: View {
    @EnvironmentObject private var app: AppController
    let claim: Claim
    @State private var reason = ""
    var body: some View {
        ScrollView {
            if let live = app.claims.first(where: { $0.id == claim.id }) {
                VStack(alignment: .leading, spacing: 18) {
                    if let item = app.items.first(where: { $0.id == live.itemID }) { ItemDetails(item: item) }
                    Text("Claimant: \(app.userName(for: live.studentID))").font(.headline)
                    StatusBadge(text: live.status.rawValue)
                    Text(live.createdAt.formatted())
                    Text("Verification Information").font(.headline)
                    Text(live.verificationInformation)
                    if live.status == .pending {
                        AppButton(title: "Approve Claim") { app.approveClaim(live) }
                        TextField("Optional rejection reason", text: $reason, axis: .vertical).textFieldStyle(.roundedBorder)
                        Button("Reject Claim", role: .destructive) { app.rejectClaim(live, reason: reason) }.buttonStyle(.bordered)
                    }
                }.padding()
            } else { ContentUnavailableView("Claim no longer available", systemImage: "tray") }
        }.appBackground().navigationTitle("Review Claim").navigationBarTitleDisplayMode(.inline)
    }
}

