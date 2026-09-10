import SwiftUI

struct EmployeeClaimsScreen: View {
    @EnvironmentObject private var app: AppController
    @State private var showPendingOnly: Bool
    init(showPendingOnly: Bool = false) { _showPendingOnly = State(initialValue: showPendingOnly) }
    private var results: [Claim] { app.claims.filter { !showPendingOnly || $0.status == .pending }.sorted { $0.createdAt > $1.createdAt } }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Claims").font(.largeTitle.bold())
                Toggle("Pending Only", isOn: $showPendingOnly)
                ForEach(results) { claim in
                    NavigationLink { EmployeeClaimReviewScreen(claim: claim) } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(app.itemName(for: claim.itemID)).font(.headline)
                            Text(app.userName(for: claim.studentID))
                            StatusBadge(text: claim.status.rawValue)
                        }.frame(maxWidth: .infinity, alignment: .leading).appCard()
                    }.buttonStyle(.plain)
                }
                if results.isEmpty { Text("No claims to show.") }
            }.padding()
        }.appBackground()
    }
}

