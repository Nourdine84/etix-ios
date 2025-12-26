import SwiftUI
import UIKit

struct OCRScannerView: UIViewControllerRepresentable {

    // ⚠️ SIGNATURE ALIGNÉE AVEC AddTicketView
    let onImageCaptured: (UIImage) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()

        controller.onCapture = { image in
            onImageCaptured(image)
        }

        controller.onCancel = {
            onCancel()
        }

        return controller
    }

    func updateUIViewController(
        _ uiViewController: CameraViewController,
        context: Context
    ) {}
}
