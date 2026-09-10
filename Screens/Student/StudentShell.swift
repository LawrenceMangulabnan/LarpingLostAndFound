import SwiftUI

struct StudentShell: View {
    var body: some View {
        TabView {
            NavigationStack { StudentHomeScreen() }.tabItem { Label("Home", systemImage: "house") }
            NavigationStack { StudentBrowseScreen() }.tabItem { Label("Browse", systemImage: "magnifyingglass") }
            NavigationStack { StudentReportScreen() }.tabItem { Label("Report", systemImage: "plus.circle") }
            NavigationStack { StudentMyItemsScreen() }.tabItem { Label("My Items", systemImage: "tray") }
            NavigationStack { StudentProfileScreen() }.tabItem { Label("Profile", systemImage: "person") }
        }.tint(AppColors.accent)
    }
}
