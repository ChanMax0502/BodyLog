import PhotosUI
import SwiftUI
import UIKit

/// 包装 PHPickerViewController（相册选择，免相册权限）。支持多选。
struct PhotoPicker: UIViewControllerRepresentable {
    var onPicked: ([UIImage]) -> Void
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 0
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        init(_ parent: PhotoPicker) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard !results.isEmpty else {
                parent.onCancel()
                return
            }

            let providers = results.map { $0.itemProvider }
            var images = Array<UIImage?>(repeating: nil, count: providers.count)
            let group = DispatchGroup()

            for (idx, provider) in providers.enumerated() {
                guard provider.canLoadObject(ofClass: UIImage.self) else { continue }
                group.enter()
                provider.loadObject(ofClass: UIImage.self) { obj, _ in
                    if let image = obj as? UIImage {
                        images[idx] = image
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) { [parent] in
                let picked = images.compactMap { $0 }
                if picked.isEmpty {
                    parent.onCancel()
                } else {
                    parent.onPicked(picked)
                }
            }
        }
    }
}
