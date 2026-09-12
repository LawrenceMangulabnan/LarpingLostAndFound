import SwiftUI
import UIKit

enum AppColors {
    static let red = Color(hex: "#C0263A")
    static let redDark = Color(hex: "#8F1C2B")
    static let redLight = Color(hex: "#C0263A").opacity(0.18)
    static let redGhost = Color(hex: "#C0263A").opacity(0.08)
    static let green = Color(hex: "#30D158")
    static let greenLight = Color(hex: "#30D158").opacity(0.15)
    static let orange = Color(hex: "#FF9F0A")
    static let orangeLight = Color(hex: "#FF9F0A").opacity(0.15)
    static let blue = Color(hex: "#4F9FFF")
    static let blueLight = Color(hex: "#4F9FFF").opacity(0.15)
    static let blueGhost = Color(hex: "#4F9FFF").opacity(0.08)
    static let purple = Color(hex: "#BF5AF2")
    static let purpleLight = Color(hex: "#BF5AF2").opacity(0.15)
    static let background = Color(hex: "#1A1A1E")
    static let card = Color(hex: "#2C2C2E")
    static let cardHi = Color(hex: "#3A3A3C")
    static let label = Color.white
    static let label2 = Color(hex: "#EBEBF5")
    static let label3 = Color(hex: "#8E8E93")
    static let placeholder = Color(hex: "#636366")
    static let fill = Color(hex: "#3A3A3C")
    static let sep = Color(hex: "#38383A")
    static let accent = red
    static let secondaryText = label3
    static let primaryText = label
    static let success = green
}

enum AppMetrics {
    static let cardRadius: CGFloat = 16
    static let buttonRadius: CGFloat = 14
    static let fieldRadius: CGFloat = 12
    static let chipRadius: CGFloat = 10
    static let pagePadding: CGFloat = 16
}

enum Campus {
    static let locations = [
        "Main Library", "Student Union", "Science Building", "Engineering Hall",
        "Athletics Center", "Campus Bookstore", "Computer Lab A", "Computer Lab B",
        "Performing Arts Center", "Dining Hall", "Dormitory A", "Dormitory B",
        "Administration Building", "Campus Coffee", "Outdoor Quad",
        "Main Library, 2nd Floor", "Student Union, Café Area", "Science Building, Room 204"
    ]
    static let phone = "tel:+15550123456"
    static let email = "mailto:lostfound@larping.edu"
    static let website = "https://larping.edu/lostfound"
    static let hours = "Mon–Fri 9am–5pm"
}

extension Color {
    init(hex: String) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)
        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}

extension View {
    func appBackground() -> some View {
        self.scrollContentBackground(.hidden)
            .background(AppColors.background.ignoresSafeArea())
    }

    func crimsonHeader() -> some View {
        self.background(
            LinearGradient(
                colors: [Color(hex: "#0D0306"), Color(hex: "#200B10"), Color(hex: "#2E1018")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    func staffHeader() -> some View {
        self.background(
            LinearGradient(
                colors: [Color(hex: "#0A0A0E"), Color(hex: "#141418"), Color(hex: "#1A1A1E")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

enum AppAppearance {
    static func apply() {
        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = UIColor(AppColors.card)
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
        UITabBar.appearance().tintColor = UIColor(AppColors.red)
        UITabBar.appearance().unselectedItemTintColor = UIColor(AppColors.label3)

        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = UIColor(AppColors.card)
        nav.titleTextAttributes = [.foregroundColor: UIColor.white]
        nav.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().tintColor = UIColor(AppColors.red)
    }
}
