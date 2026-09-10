import SwiftUI
import PhotosUI
import UIKit

struct PhotoPickerButton: View {
    @Binding var imageData: Data?
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
                    .fill(AppTheme.card)
                    .frame(height: 150)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 32))
                                .foregroundStyle(AppTheme.crimson)

                            Text("No photo selected")
                                .foregroundStyle(AppTheme.secondaryText)
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
                    .background(AppTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    guard let data = try? await newValue?.loadTransferable(
                        type: Data.self
                    ) else {
                        return
                    }

                    await MainActor.run {
                        imageData = data
                    }
                }
            }
        }
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Binding var imageData: Data?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(
        context: Context
    ) -> UIImagePickerController {

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = true

        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {}

    final class Coordinator: NSObject,
        UINavigationControllerDelegate,
        UIImagePickerControllerDelegate {

        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [
                UIImagePickerController.InfoKey: Any
            ]
        ) {
            let image =
                (info[.editedImage] as? UIImage)
                ?? (info[.originalImage] as? UIImage)

            parent.imageData = image?.jpegData(compressionQuality: 0.8)
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(
            _ picker: UIImagePickerController
        ) {
            parent.dismiss()
        }
    }
}