import SwiftUI
import AVFoundation

struct OCRScannerView: UIViewControllerRepresentable {

    let onCapture: (UIImage) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        vc.onCapture = onCapture
        vc.onCancel = onCancel
        return vc
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}
