import SwiftUI

struct EmployeeShell: View {
    @EnvironmentObject private var app: AppController
    var body: some View {
        TabView(selection: $app.employeeTab) {
            NavigationStack { EmployeeDashboardScreen() }
                .tabItem { Label("Dashboard", systemImage: "house.fill") }
                .tag(EmployeeTab.dashboard)
            NavigationStack { EmployeeReportsScreen() }
                .tabItem { Label("Reports", systemImage: "doc.text.fill") }
                .tag(EmployeeTab.reports)
            NavigationStack { EmployeeClaimsScreen() }
                .tabItem { Label("Claims", systemImage: "checkmark.seal.fill") }
                .tag(EmployeeTab.claims)
            NavigationStack { EmployeeItemsScreen() }
                .tabItem { Label("Items", systemImage: "shippingbox.fill") }
                .tag(EmployeeTab.items)
            NavigationStack { EmployeeProfileScreen() }
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(EmployeeTab.profile)
        }
        .tint(AppColors.red)
    }
}
