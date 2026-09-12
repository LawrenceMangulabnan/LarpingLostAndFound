import SwiftUI

struct StudentShell: View {
    @EnvironmentObject private var app: AppController
    var body: some View {
        TabView(selection: $app.studentTab) {
            NavigationStack { StudentHomeScreen() }
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(StudentTab.home)
            NavigationStack { StudentBrowseScreen() }
                .tabItem { Label("Browse", systemImage: "square.grid.2x2.fill") }
                .tag(StudentTab.browse)
            NavigationStack { StudentReportScreen() }
                .tabItem { Label("Report", systemImage: "plus.circle.fill") }
                .tag(StudentTab.report)
            NavigationStack { StudentMyItemsScreen() }
                .tabItem { Label("My Items", systemImage: "tray.full.fill") }
                .tag(StudentTab.myItems)
            NavigationStack { StudentProfileScreen() }
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(StudentTab.profile)
        }
        .tint(AppColors.red)
    }
}
