import SwiftUI

struct AboutScreen: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var app: AppController
    @State private var sheet = ""
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    BrandMark(size: 80)
                    Text("Campus Lost & Found").font(.system(size: 22, weight: .black)).foregroundStyle(AppColors.label)
                    Text("Larping University").foregroundStyle(AppColors.label3)
                    Text("Version 1.0.0").font(.system(size: 12)).foregroundStyle(AppColors.label3)
                        .padding(.horizontal, 12).padding(.vertical, 4).background(AppColors.cardHi).clipShape(Capsule())
                }.padding(.top, 16)
                SettingsSection(title: "About the App") {
                    Text("Campus Lost & Found is an official Larping University application designed to help students and staff reconnect with lost belongings quickly and efficiently.")
                        .font(.system(size: 14)).foregroundStyle(AppColors.label2).padding(16)
                }
                SettingsSection(title: "Information") {
                    Button { sheet = "privacy" } label: { SettingsRow(title: "Privacy Policy", icon: "🔒") }
                    Divider().background(AppColors.sep)
                    Button { sheet = "terms" } label: { SettingsRow(title: "Terms of Service", icon: "📄") }
                    Divider().background(AppColors.sep)
                    Button { sheet = "guidelines" } label: { SettingsRow(title: "Community Guidelines", icon: "📜") }
                }
                SettingsSection(title: "Contact") {
                    Button { open(Campus.website) } label: { SettingsRow(title: "larping.edu/lostfound", icon: "🌐") }
                    Divider().background(AppColors.sep)
                    Button { open(Campus.email) } label: { SettingsRow(title: "lostfound@larping.edu", icon: "✉️") }
                }
                Text("© 2026 Larping University. All rights reserved.").font(.system(size: 12)).foregroundStyle(AppColors.label3)
            }.padding(16)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("About")
        .sheet(isPresented: Binding(get: { !sheet.isEmpty }, set: { if !$0 { sheet = "" } })) {
            NavigationStack {
                ScrollView {
                    Text(bodyText).foregroundStyle(AppColors.label2).padding()
                }
                .background(AppColors.background)
                .navigationTitle(sheet.capitalized)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { sheet = "" } } }
            }
        }
    }
    private var bodyText: String {
        switch sheet {
        case "privacy": return "This local academic prototype stores accounts, photos, reports, and claims in memory on this device. Data is not uploaded to a cloud database and is cleared when the app restarts. Avoid entering sensitive personal information."
        case "terms": return "Campus Lost & Found is for academic demonstration. Approval of a report or claim does not replace in-person identity and ownership verification when collecting an item from the Lost & Found office."
        default: return "Provide accurate descriptions. Keep proof of ownership in your claim. Staff review reports and claims before approval. Do not submit false reports."
        }
    }
    private func open(_ value: String) {
        guard let url = URL(string: value) else { return }
        openURL(url) { if !$0 { app.errorMessage = "This device cannot open that link." } }
    }
}
