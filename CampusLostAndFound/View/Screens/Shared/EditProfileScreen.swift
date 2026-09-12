import SwiftUI
import PhotosUI
import UIKit

struct EditProfileScreen: View {
    @EnvironmentObject private var app: AppController
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var universityID = ""
    @State private var photo: Data?
    @State private var picker: PhotosPickerItem?
    @State private var saved = false
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let user = app.currentUser {
                    VStack(spacing: 12) {
                        if let photo, let image = UIImage(data: photo) {
                            Image(uiImage: image).resizable().scaledToFill().frame(width: 80, height: 80).clipShape(Circle())
                        } else {
                            AvatarView(user: User(id: user.id, fullName: name.isEmpty ? user.fullName : name, email: user.email, password: user.password, universityID: user.universityID, role: user.role, profilePhotoData: user.profilePhotoData), size: 80)
                        }
                        PhotosPicker("Change Photo", selection: $picker, matching: .images).foregroundStyle(AppColors.red)
                    }
                }
                if saved { Text("✓ Profile updated!").font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.green).frame(maxWidth: .infinity).padding().background(AppColors.greenLight).clipShape(RoundedRectangle(cornerRadius: 12)) }
                LabeledField(label: "Full Name", placeholder: "Your full name", text: $name)
                LabeledField(label: "University Email", placeholder: "you@larping.edu", text: $email)
                LabeledField(label: "Student / Employee ID", placeholder: "ID", text: $universityID)
                AppButton(title: "Save Changes") {
                    if app.updateProfile(fullName: name, universityID: universityID, email: email, photoData: photo) {
                        saved = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { dismiss() }
                    }
                }
            }.padding(16)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Edit Profile")
        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Save") { _ = app.updateProfile(fullName: name, universityID: universityID, email: email, photoData: photo); dismiss() }.foregroundStyle(AppColors.red) } }
        .onAppear {
            name = app.currentUser?.fullName ?? ""
            email = app.currentUser?.email ?? ""
            universityID = app.currentUser?.universityID ?? ""
            photo = app.currentUser?.profilePhotoData
        }
        .task(id: picker?.itemIdentifier) {
            guard let picker else { return }
            if let data = try? await picker.loadTransferable(type: Data.self) { photo = ReportPhoto.prepare(data) ?? data }
        }
    }
}
