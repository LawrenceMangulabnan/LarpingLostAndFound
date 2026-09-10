import SwiftUI

struct EmployeeShell: View {
    var body: some View {
        TabView {
            NavigationStack { EmployeeDashboardScreen() }.tabItem { Label("Dashboard", systemImage: "square.grid.2x2") }
            NavigationStack { EmployeeReportsScreen() }.tabItem { Label("Reports", systemImage: "doc.text") }
            NavigationStack { EmployeeClaimsScreen() }.tabItem { Label("Claims", systemImage: "checkmark.seal") }
            NavigationStack { EmployeeItemsScreen() }.tabItem { Label("Items", systemImage: "shippingbox") }
            NavigationStack { EmployeeProfileScreen() }.tabItem { Label("Profile", systemImage: "person") }
        }.tint(AppColors.accent)
    }
}
