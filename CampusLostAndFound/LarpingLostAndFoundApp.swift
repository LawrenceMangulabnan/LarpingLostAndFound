import SwiftUI

@main
struct LarpingLostAndFoundApp: App {
    @StateObject private var app = AppController(repository: MockRepository())
    init() { AppAppearance.apply() }
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(app)
                .preferredColorScheme(.dark)
                .tint(AppColors.red)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var app: AppController
    var body: some View {
        Group {
            if let user = app.currentUser {
                switch user.role {
                case .student: StudentShell()
                case .employee: EmployeeShell()
                }
            } else {
                LoginScreen()
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .alert("Campus Lost & Found", isPresented: Binding(
            get: { app.errorMessage != nil || app.successMessage != nil },
            set: { if !$0 { app.errorMessage = nil; app.successMessage = nil } }
        )) {
            Button("OK", role: .cancel) { app.errorMessage = nil; app.successMessage = nil }
        } message: {
            Text(app.errorMessage ?? app.successMessage ?? "")
        }
    }
}
