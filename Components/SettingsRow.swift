import SwiftUI

struct SettingsRow: View {
    let title: String
    let icon: String
    var body: some View { Label(title, systemImage: icon).padding(.vertical, 6) }
}

