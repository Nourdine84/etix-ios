import UIKit
import AVFoundation

final class CameraViewController: UIViewController {

    var onCapture: ((UIImage) -> Void)?
    var onCancel: (() -> Void)?

    private let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    private var isSessionConfigured = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCameraIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }

    // MARK: - Camera logic

    private func startCameraIfNeeded() {
        guard !isSessionConfigured else { return }
        isSessionConfigured = true

        DispatchQueue.global(qos: .userInitiated).async {

            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            guard
                let device = AVCaptureDevice.default(for: .video),
                let input = try? AVCaptureDeviceInput(device: device),
                self.session.canAddInput(input)
            else {
                self.session.commitConfiguration()
                return
            }

            self.session.addInput(input)

            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }

            self.session.commitConfiguration()
            self.session.startRunning()

            DispatchQueue.main.async {
                self.setupPreview()
            }
        }
    }

    private func stopSession() {
        guard session.isRunning else { return }

        DispatchQueue.global(qos: .background).async {
            self.session.stopRunning()
        }
    }

    private func setupPreview() {
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.insertSublayer(preview, at: 0)
        previewLayer = preview
    }

    // MARK: - UI

    private func setupUI() {

        let captureButton = UIButton(type: .system)
        captureButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        captureButton.tintColor = .white
        captureButton.frame = CGRect(
            x: view.bounds.midX - 30,
            y: view.bounds.height - 100,
            width: 60,
            height: 60
        )
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)

        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        closeButton.frame = CGRect(x: 20, y: 50, width: 40, height: 40)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(closeButton)
    }

    // MARK: - Actions

    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    @objc private func close() {
        stopSession()
        dismiss(animated: true) {
            self.onCancel?()
        }
    }
}

// MARK: - AVCapture Delegate

extension CameraViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard
            let data = photo.fileDataRepresentation(),
            let image = UIImage(data: data)
        else { return }

        stopSession()
        dismiss(animated: true) {
            self.onCapture?(image)
        }
    }
}
