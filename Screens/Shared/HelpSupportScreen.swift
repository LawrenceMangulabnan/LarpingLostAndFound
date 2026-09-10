import SwiftUI

struct HelpSupportScreen: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var app: AppController
    var body: some View {
        Form {
            Section("Frequently Asked Questions") {
                DisclosureGroup("How do I report an item?") { Text("Open Report, choose Lost or Found, enter the item details and an optional photo, then submit.") }
                DisclosureGroup("How do claims work?") { Text("Open an approved item reported by someone else and select I Think This Is Mine. Provide proof of ownership for staff to review.") }
                DisclosureGroup("Why is my report pending?") { Text("Staff must verify reports before they appear in Browse.") }
                DisclosureGroup("Can I edit or delete my report?") { Text("Open My Items, select your report, then save changes or confirm deletion. Editing an approved or rejected report requires verification again.") }
            }
            Section("Contact") {
                Button("Email Lost & Found", systemImage: "envelope") { contact("mailto:lostandfound@larping.edu") }
                Button("Call Support", systemImage: "phone") { contact("tel:+630000000000") }
                Text("These are prototype contact details for Larping University.").font(.caption)
            }
        }.appBackground().navigationTitle("Help & Support")
    }
    private func contact(_ address: String) {
        guard let url = URL(string: address) else { return }
        openURL(url) { accepted in
            if !accepted { app.errorMessage = "This device cannot open that contact action. Try a device with Mail or Phone configured." }
        }
    }
}
