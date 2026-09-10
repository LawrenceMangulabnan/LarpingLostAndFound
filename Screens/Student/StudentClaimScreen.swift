import SwiftUI

struct StudentClaimScreen: View {
    @EnvironmentObject private var app: AppController
    @Environment(\.dismiss) private var dismiss
    let item: LostFoundItem
    @State private var verification = ""
    var body: some View {
        Form {
            Section {
                Text(app.itemName(for: item.id)).font(.headline)
                Text(app.items.first(where: { $0.id == item.id })?.location ?? item.location)
            }
            Section("Proof of ownership") {
                Text("Describe unique contents, marks, a serial number, color/details, or other proof of ownership.").font(.subheadline)
                TextField("Verification information", text: $verification, axis: .vertical).lineLimit(5...10)
            }
            AppButton(title: "Submit Claim") {
                if app.submitClaim(item: item, verification: verification) { dismiss() }
            }
        }.appBackground().navigationTitle("Claim Item")
    }
}
