import SwiftUI
import UIKit
import SnapKit

struct ImagePicker: UIViewControllerRepresentable {
    enum Source { case camera }
    let source: Source
    var onPicked: (UIImage) -> Void
    var onCancel: () -> Void
    var onAlbum: (() -> Void)?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = false
        vc.showsCameraControls = false
        vc.delegate = context.coordinator
        vc.view.backgroundColor = .black
        let safeTop = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first(where: \.isKeyWindow)?
            .safeAreaInsets.top ?? 47
        vc.cameraViewTransform = CGAffineTransform(translationX: 0, y: safeTop + 70)
        context.coordinator.picker = vc

        let controls = CameraControlsView(coordinator: context.coordinator)
        vc.view.addSubview(controls)
        controls.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        context.coordinator.controlsView = controls
        return vc
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        context.coordinator.controlsView.map { uiViewController.view.bringSubviewToFront($0) }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        weak var picker: UIImagePickerController?
        weak var controlsView: CameraControlsView?
        var flashMode: UIImagePickerController.CameraFlashMode = .auto

        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true)
            if let image = info[.originalImage] as? UIImage {
                parent.onPicked(image)
            } else {
                parent.onCancel()
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            parent.onCancel()
        }

        @objc func handleClose()   { parent.onCancel() }
        @objc func handleCapture() { picker?.takePicture() }
        @objc func handleAlbum()   { parent.onAlbum?() }

        @objc func handleFlip() {
            guard let picker else { return }
            picker.cameraDevice = picker.cameraDevice == .rear ? .front : .rear
        }

        @objc func handleFlash() {
            guard let picker else { return }
            switch flashMode {
            case .auto: flashMode = .on;   picker.cameraFlashMode = .on
            case .on:   flashMode = .off;  picker.cameraFlashMode = .off
            case .off:  flashMode = .auto; picker.cameraFlashMode = .auto
            @unknown default: break
            }
            controlsView?.updateFlash(mode: flashMode)
        }
    }
}

// MARK: - Controls overlay

final class CameraControlsView: UIView {

    private let coordinator: ImagePicker.Coordinator

    private lazy var closeButton: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        btn.layer.cornerRadius = 18
        btn.addTarget(coordinator, action: #selector(ImagePicker.Coordinator.handleClose), for: .touchUpInside)
        return btn
    }()

    private lazy var flashButton: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        btn.setImage(UIImage(systemName: "bolt.badge.a.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        btn.layer.cornerRadius = 18
        btn.addTarget(coordinator, action: #selector(ImagePicker.Coordinator.handleFlash), for: .touchUpInside)
        return btn
    }()

    private lazy var shutterButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 36
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        btn.layer.borderWidth = 4
        btn.addTarget(coordinator, action: #selector(ImagePicker.Coordinator.handleCapture), for: .touchUpInside)
        return btn
    }()

    private lazy var albumButton: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        btn.setImage(UIImage(systemName: "photo", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        btn.layer.cornerRadius = 18
        btn.addTarget(coordinator, action: #selector(ImagePicker.Coordinator.handleAlbum), for: .touchUpInside)
        return btn
    }()

    private lazy var flipButton: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        btn.setImage(UIImage(systemName: "arrow.triangle.2.circlepath.camera.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        btn.layer.cornerRadius = 18
        btn.addTarget(coordinator, action: #selector(ImagePicker.Coordinator.handleFlip), for: .touchUpInside)
        return btn
    }()


    init(coordinator: ImagePicker.Coordinator) {
        self.coordinator = coordinator
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = .clear
        isUserInteractionEnabled = true

        addSubview(closeButton)
        addSubview(flashButton)
        addSubview(shutterButton)
        addSubview(albumButton)
        addSubview(flipButton)

        shutterButton.snp.makeConstraints { make in
            make.width.height.equalTo(72)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide).inset(72)
        }

        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(safeAreaLayoutGuide).offset(8)
        }

        flashButton.snp.makeConstraints { make in
            make.width.equalTo(44)
            make.height.equalTo(36)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(closeButton)
        }

        albumButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.leading.equalToSuperview().offset(32)
            make.centerY.equalTo(shutterButton)
        }

        flipButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.trailing.equalToSuperview().inset(32)
            make.centerY.equalTo(shutterButton)
        }
    }

    func updateFlash(mode: UIImagePickerController.CameraFlashMode) {
        let name: String
        switch mode {
        case .on:   name = "bolt.fill"
        case .off:  name = "bolt.slash.fill"
        default:    name = "bolt.badge.a.fill"
        }
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        flashButton.setImage(UIImage(systemName: name, withConfiguration: cfg), for: .normal)
    }
}
