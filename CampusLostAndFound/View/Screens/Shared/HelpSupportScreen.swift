import SwiftUI

struct HelpSupportScreen: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var app: AppController
    @State private var open: Int?
    @State private var contact = false
    @State private var hours = false
    private let faqs = [
        ("How do I report a lost item?", "Tap the Report tab, select Lost, fill in the item details including a photo, name, category, location, and date, then tap Submit Report."),
        ("How do I report a found item?", "Tap the Report tab, select Found, and provide all item details. Found items are reviewed by staff and posted for potential claimants."),
        ("How do I claim an item?", "Browse found items, open the item details page, and tap I Think This Is Mine. Provide identifying details that only the true owner would know."),
        ("How long does verification take?", "Staff typically reviews reports and claims within 24 hours on business days. You will receive a notification when the status is updated."),
        ("What happens after my claim is approved?", "You will be notified to visit the Lost & Found office with your student ID to collect your item. Items must be collected within 14 days.")
    ]
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SettingsSection(title: "Frequently Asked Questions") {
                    ForEach(Array(faqs.enumerated()), id: \.offset) { index, faq in
                        Button { open = open == index ? nil : index } label: {
                            HStack {
                                Text("❓")
                                Text(faq.0).foregroundStyle(AppColors.label).font(.system(size: 15)).multilineTextAlignment(.leading)
                                Spacer()
                                Image(systemName: "chevron.right").rotationEffect(.degrees(open == index ? 90 : 0)).foregroundStyle(AppColors.label3)
                            }.padding(.horizontal, 16).padding(.vertical, 13)
                        }.buttonStyle(.plain)
                        if open == index {
                            Text(faq.1).font(.system(size: 14)).foregroundStyle(AppColors.label2)
                                .padding(12).background(AppColors.cardHi).clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal, 16).padding(.bottom, 12)
                        }
                        if index < faqs.count - 1 { Divider().background(AppColors.sep) }
                    }
                }
                SettingsSection(title: "Contact") {
                    Button { contact = true } label: { SettingsRow(title: "Contact Lost & Found Office", icon: "📞") }
                }
            }.padding(16)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Help & Support")
        .confirmationDialog("Contact Lost & Found", isPresented: $contact) {
            Button("Call Office: (555) 012-3456") { open(Campus.phone) }
            Button("Email: lostfound@larping.edu") { open(Campus.email) }
            Button("Office Hours: Mon–Fri 9am–5pm") { hours = true }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Office Hours", isPresented: $hours) { Button("OK", role: .cancel) {} } message: { Text(Campus.hours) }
    }
    private func open(_ value: String) {
        guard let url = URL(string: value) else { return }
        openURL(url) { if !$0 { app.errorMessage = "This device cannot open that contact action." } }
    }
}
