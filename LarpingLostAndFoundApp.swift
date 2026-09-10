import SwiftUI

@main
struct LarpingLostAndFoundApp: App {
    @StateObject private var app = AppController()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(app)
                .preferredColorScheme(.dark)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var app: AppController

    var body: some View {
        Group {
            if let user = app.currentUser {
                if user.role == .student {
                    StudentShell()
                } else {
                    EmployeeShell()
                }
            } else {
                LoginScreen()
            }
        }
        .tint(AppTheme.crimson)
    }
}