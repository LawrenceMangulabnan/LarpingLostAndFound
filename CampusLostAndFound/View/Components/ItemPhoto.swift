import SwiftUI
import PhotosUI
import UIKit
import AVFoundation

struct ReportPhotoWell: View {
    @EnvironmentObject private var app: AppController
    @Binding var imageData: Data?
    @Binding var camera: Bool
    @State private var pickerItem: PhotosPickerItem?
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Photo").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.label3).textCase(.uppercase)
            if let imageData, let image = UIImage(data: imageData) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image).resizable().scaledToFill().frame(height: 200).clipped()
                    Button { self.imageData = nil } label: {
                        Image(systemName: "xmark").font(.system(size: 10, weight: .bold)).foregroundStyle(.white)
                            .frame(width: 28, height: 28).background(.black.opacity(0.65)).clipShape(Circle())
                    }
                    .padding(10)
                    Text("✓ Photo added").font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                        .padding(.horizontal, 10).padding(.vertical, 4).background(AppColors.green).clipShape(Capsule())
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .padding(10)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                HStack(spacing: 12) {
                    Button {
                        Task { await requestCamera() }
                    } label: {
                        VStack(spacing: 6) {
                            Text("📷").font(.system(size: 28))
                            Text("Camera").font(.system(size: 13, weight: .semibold)).foregroundStyle(AppColors.red)
                        }
                        .frame(maxWidth: .infinity).frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6])).foregroundStyle(AppColors.red))
                    }
                    .buttonStyle(.plain)
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        VStack(spacing: 6) {
                            Text("🖼").font(.system(size: 28))
                            Text("Photos").font(.system(size: 13, weight: .semibold)).foregroundStyle(AppColors.label3)
                        }
                        .frame(maxWidth: .infinity).frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6])).foregroundStyle(AppColors.sep))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .task(id: pickerItem?.itemIdentifier) {
            guard let pickerItem else { return }
            if let data = try? await pickerItem.loadTransferable(type: Data.self), let jpeg = ReportPhoto.prepare(data) {
                imageData = jpeg
            } else {
                app.errorMessage = "Unable to read this photo. Choose another image."
            }
        }
    }

    @MainActor private func requestCamera() async {
        guard let usage = Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") as? String,
              !usage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            app.errorMessage = "Camera setup is missing. Add NSCameraUsageDescription to the app target in Xcode. You can still choose a library photo."
            return
        }
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            app.errorMessage = "Camera unavailable. Use the photo library on the simulator."
            return
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: camera = true
        case .notDetermined:
            if await AVCaptureDevice.requestAccess(for: .video) { camera = true }
            else { app.errorMessage = "Camera access is denied. Enable it in Settings or choose a library photo." }
        default:
            app.errorMessage = "Camera access is denied or restricted. Enable it in Settings or choose a library photo."
        }
    }
}
