import SwiftUI
import PhotosUI
import UIKit

struct PhotoPickerButton: View {
    @EnvironmentObject private var app: AppController
    @Binding var imageData: Data?
    @Binding var isLoading: Bool
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 12) {
            if let imageData,
               let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 190)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            } else {
                RoundedRectangle(cornerRadius: 18)
                    .fill(AppColors.card)
                    .frame(height: 150)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 32))
                                .foregroundStyle(AppColors.accent)

                            Text("No photo selected")
                                .foregroundStyle(AppColors.secondaryText)
                        }
                    }
            }

            PhotosPicker(
                selection: $selectedPhoto,
                matching: .images
            ) {
                Label("Choose Photo", systemImage: "photo")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .task(id: selectedPhoto) {
                guard let selectedPhoto else { return }
                isLoading = true
                defer { if !Task.isCancelled { isLoading = false } }
                do {
                    guard let data = try await selectedPhoto.loadTransferable(type: Data.self),
                          let jpeg = ReportPhoto.prepare(data) else {
                        app.errorMessage = "Unable to read this photo. Choose another image."
                        return
                    }
                    guard !Task.isCancelled else { return }
                    imageData = jpeg
                } catch {
                    if !Task.isCancelled { app.errorMessage = "Unable to load the selected photo. Please try again." }
                }
            }
            if isLoading { ProgressView("Loading photo…") }
        }
    }
}

