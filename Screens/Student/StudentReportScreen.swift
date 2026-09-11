import SwiftUI
import UIKit
import AVFoundation

struct StudentReportScreen: View {
    @EnvironmentObject private var app: AppController
    @State private var draft = ItemDraft()
    @State private var camera = false
    @State private var photoLoading = false
    @State private var photoSession = UUID()
    var body: some View {
        Form {
            Section { Text("Report an Item").font(.largeTitle.bold()) }
            ItemFormFields(draft: $draft)
            Section("Photo") {
                PhotoPickerButton(imageData: $draft.photoData, isLoading: $photoLoading)
                    .id(photoSession)
                Button {
                    Task { await openCamera() }
                } label: {
                    Label("Take Photo", systemImage: "camera")
                }.disabled(photoLoading)
                if draft.photoData != nil { Button("Remove Photo", role: .destructive) {
                    photoSession = UUID(); photoLoading = false; draft.photoData = nil
                } }
            }
            AppButton(title: "Submit Report") {
                if app.addItem(photoData: draft.photoData, itemName: draft.name, category: draft.category, customCategory: draft.customCategory, location: draft.location, date: draft.date, description: draft.description, type: draft.type) {
                    draft = ItemDraft(); photoSession = UUID()
                }
            }.disabled(photoLoading)
        }.appBackground()
            .sheet(isPresented: $camera) { CameraImagePicker(imageData: $draft.photoData).ignoresSafeArea() }
    }

    @MainActor private func openCamera() async {
        guard let usage = Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") as? String,
              !usage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            app.errorMessage = "Camera setup is missing. Add NSCameraUsageDescription to the app target in Xcode. You can still choose a library photo."
            return
        }
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            app.errorMessage = "Camera unavailable. Use the photo library on the simulator."
            return
        }
        let authorized: Bool
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: authorized = true
        case .notDetermined: authorized = await AVCaptureDevice.requestAccess(for: .video)
        default: authorized = false
        }
        if authorized { camera = true }
        else { app.errorMessage = "Camera access is denied or restricted. Enable it in Settings or choose a library photo." }
    }
}

