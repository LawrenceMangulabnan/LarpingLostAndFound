import SwiftUI

struct EditProfileScreen: View {
    @EnvironmentObject private var app: AppController
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var universityID = ""
    @State private var loaded = false
    var body: some View {
        Form {
            TextField("Full name", text: $name)
            TextField("University ID", text: $universityID)
            LabeledContent("Email", value: app.currentUser?.email ?? "")
            AppButton(title: "Save Profile") {
                if app.updateProfile(fullName: name, universityID: universityID) { dismiss() }
            }
        }.appBackground().navigationTitle("Edit Profile")
            .onAppear {
                if !loaded {
                    name = app.currentUser?.fullName ?? ""; universityID = app.currentUser?.universityID ?? ""; loaded = true
                }
            }
    }
}
