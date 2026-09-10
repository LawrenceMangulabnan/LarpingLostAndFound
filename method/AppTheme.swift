import SwiftUI

enum AppTheme {
    static let background = Color(hex: "060E24")
    static let card = Color(hex: "1A1A1E")
    static let secondaryCard = Color(hex: "2C2C2E")

    static let crimson = Color(hex: "C0263A")
    static let crimsonSoft = Color(hex: "32131A")

    static let secondaryText = Color(hex: "8E8E93")
    static let secondaryPrimaryText = Color(hex: "D1D1D6")

    static let success = Color(hex: "34C759")
}

extension Color {
    init(hex: String) {
        let value = UInt64(hex, radix: 16) ?? 0

        self.init(
            red: Double((value >> 16) & 255) / 255,
            green: Double((value >> 8) & 255) / 255,
            blue: Double(value & 255) / 255
        )
    }
}

extension View {
    func appBackground() -> some View {
        self
            .background(
                AppTheme.background
                    .ignoresSafeArea()
            )
    }

    func appCard() -> some View {
        self
            .padding()
            .background(AppTheme.card)
            .clipShape(
                RoundedRectangle(cornerRadius: 18)
            )
    }
}