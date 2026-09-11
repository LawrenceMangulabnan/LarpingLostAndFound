import SwiftUI
import UIKit

struct CameraImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Binding var imageData: Data?

    func makeCoordinator() -> Coordinator {
        Coordinator()
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
    ) {
        context.coordinator.imageData = $imageData
        context.coordinator.onDismiss = { dismiss() }
    }

    final class Coordinator: NSObject,
        UINavigationControllerDelegate,
        UIImagePickerControllerDelegate {

        var imageData: Binding<Data?> = .constant(nil)
        var onDismiss: () -> Void = {}

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [
                UIImagePickerController.InfoKey: Any
            ]
        ) {
            let image =
                (info[.editedImage] as? UIImage)
                ?? (info[.originalImage] as? UIImage)

            if let data = image?.jpegData(compressionQuality: 0.8), let prepared = ReportPhoto.prepare(data) {
                imageData.wrappedValue = prepared
            }
            onDismiss()
        }

        func imagePickerControllerDidCancel(
            _ picker: UIImagePickerController
        ) {
            onDismiss()
        }
    }
}
