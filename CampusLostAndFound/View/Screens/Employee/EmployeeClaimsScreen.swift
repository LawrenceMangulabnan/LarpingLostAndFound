import SwiftUI

struct EmployeeClaimsScreen: View {
    @EnvironmentObject private var app: AppController
    @State private var tab = "pending"
    @State private var confirm: (Claim, String)?
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Review Claims").font(.system(size: 22, weight: .bold)).foregroundStyle(AppColors.label)
                CapsuleSegment(options: [("pending", "Pending (\(app.claims.filter { $0.status == .pending }.count))"), ("approved", "Approved"), ("rejected", "Rejected")], value: $tab)
                let list = app.claims.filter {
                    (tab == "pending" && $0.status == .pending) || (tab == "approved" && $0.status == .approved) || (tab == "rejected" && $0.status == .rejected)
                }.sorted { $0.createdAt > $1.createdAt }
                if list.isEmpty {
                    EmptyState(emoji: tab == "pending" ? "⏳" : "✅", title: "No \(tab) claims")
                } else {
                    ForEach(list) { claim in
                        claimCard(claim)
                    }
                }
            }.padding(16)
        }
        .background(AppColors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog(confirm?.1 == "approved" ? "Approve this claim?" : "Reject this claim?", isPresented: Binding(get: { confirm != nil }, set: { if !$0 { confirm = nil } }), titleVisibility: .visible) {
            if confirm?.1 == "rejected" {
                Button("Reject Claim", role: .destructive) {
                    if let confirm { app.rejectClaim(confirm.0, reason: "") }
                    self.confirm = nil
                }
            } else {
                Button("Approve Claim") {
                    if let confirm { app.approveClaim(confirm.0) }
                    self.confirm = nil
                }
            }
            Button("Cancel", role: .cancel) { confirm = nil }
        } message: {
            Text(confirm?.1 == "approved" ? "The item will be marked as Claimed. The student will be notified to collect it." : "The claim will be rejected. The student will be notified.")
        }
    }

    private func claimCard(_ claim: Claim) -> some View {
        let item = app.items.first { $0.id == claim.itemID }
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                NavigationLink { EmployeeClaimReviewScreen(claim: claim) } label: {
                    HStack {
                        if let item { ItemPhoto(item: item).frame(width: 56, height: 56).clipShape(RoundedRectangle(cornerRadius: 10)) }
                        VStack(alignment: .leading) {
                            Text(app.itemName(for: claim.itemID)).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.label)
                            Text(item.map { "\($0.displayCategory) · \($0.building)" } ?? "").font(.system(size: 12)).foregroundStyle(AppColors.label3)
                        }
                        Spacer()
                    }
                }.buttonStyle(.plain)
                StatusBadge(text: claim.status.shortLabel)
            }
            HStack {
                Text(String(app.userName(for: claim.studentID).prefix(1))).font(.system(size: 13, weight: .bold)).foregroundStyle(AppColors.red)
                    .frame(width: 32, height: 32).background(AppColors.redLight).clipShape(Circle())
                VStack(alignment: .leading) {
                    Text(app.userName(for: claim.studentID)).font(.system(size: 14, weight: .semibold)).foregroundStyle(AppColors.label)
                    Text("Submitted \(claim.createdAt.formatted(date: .abbreviated, time: .omitted))").font(.system(size: 12)).foregroundStyle(AppColors.label3)
                }
            }
            block("Appearance", claim.appearance)
            block("Contents / Details", claim.contents.isEmpty ? claim.verificationInformation : claim.contents)
            if !claim.context.isEmpty { block("Context", claim.context) }
            if tab == "pending" {
                HStack {
                    Button { confirm = (claim, "approved") } label: {
                        Text("✓ Approve").fontWeight(.bold).foregroundStyle(.white).frame(maxWidth: .infinity).padding(12).background(AppColors.green).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Button { confirm = (claim, "rejected") } label: {
                        Text("✗ Reject").fontWeight(.bold).foregroundStyle(AppColors.red).frame(maxWidth: .infinity).padding(12).background(AppColors.redLight).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding(16).background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func block(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.system(size: 11, weight: .semibold)).foregroundStyle(AppColors.label3).textCase(.uppercase)
            Text(value.isEmpty ? "—" : value).font(.system(size: 14)).foregroundStyle(AppColors.label2)
        }.padding(12).frame(maxWidth: .infinity, alignment: .leading).background(AppColors.cardHi).clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
