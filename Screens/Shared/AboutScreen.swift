import SwiftUI

struct AboutScreen: View {
    var body: some View {
        Form {
            Section {
                Text("Campus Lost & Found").font(.title.bold())
                Text("Larping University")
                Text("Version 1.0.0")
            }
            Section("Purpose") { Text("Help the campus community report lost and found belongings and reunite owners with their items.") }
            Section("Privacy") { Text("This is currently a local academic prototype without a real cloud database. Accounts, passwords, photos, reports, and claims are held in memory and disappear when the app restarts. Use test credentials and avoid sensitive information.") }
            Section("Guidelines") { Text("Provide accurate descriptions. Keep proof of ownership in your claim. Staff review reports and claims before approval.") }
            Section("Terms") { Text("This prototype is for academic demonstration. Approval does not replace in-person identity and ownership verification when collecting an item.") }
        }.appBackground().navigationTitle("About")
    }
}
