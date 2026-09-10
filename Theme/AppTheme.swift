import SwiftUI

enum AppColors {

    static let background = Color(
        hex: "#060E24"
    )

    static let card = Color(
        hex: "#1A1A1E"
    )

    static let elevated = Color(
        hex: "#2C2C2E"
    )

    static let accent = Color(
        hex: "#C0263A"
    )

    static let accentMuted = Color(
        hex: "#32131A"
    )

    static let secondaryText = Color(
        hex: "#8E8E93"
    )

    static let primaryText = Color.white

    static let success = Color(
        hex: "#34C759"
    )
}


extension Color {

    init(hex: String) {

        let hex = hex.replacingOccurrences(
            of: "#",
            with: ""
        )


        var value: UInt64 = 0

        Scanner(string: hex)
            .scanHexInt64(&value)


        let red: Double

        let green: Double

        let blue: Double


        if hex.count == 6 {

            red = Double(
                (value >> 16) & 0xFF
            ) / 255


            green = Double(
                (value >> 8) & 0xFF
            ) / 255


            blue = Double(
                value & 0xFF
            ) / 255

        } else {

            red = 1

            green = 1

            blue = 1
        }


        self.init(
            red: red,
            green: green,
            blue: blue
        )
    }
}


struct AppCardModifier: ViewModifier {

    func body(
        content: Content
    ) -> some View {

        content
            .padding()
            .background(
                AppColors.card
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
            )
    }
}


extension View {

    func appBackground() -> some View {
        self.scrollContentBackground(.hidden)
            .background(AppColors.background.ignoresSafeArea())
    }

    func appCard() -> some View {

        modifier(
            AppCardModifier()
        )
    }
}
