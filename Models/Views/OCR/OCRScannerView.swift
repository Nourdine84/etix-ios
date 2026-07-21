import SwiftUI
import VisionKit

/// Pur wrapper de capture autour de `VNDocumentCameraViewController`
/// (ADR-0004, Option C). Ne fait QUE capturer : il retourne l'image de la
/// première page. La reconnaissance de texte (TextRecognizer) et le parsing
/// (ReceiptParser) sont orchestrés en aval par `ScannerIntroView`, hors du
/// main thread et avec un écran de traitement.
struct OCRScannerView: UIViewControllerRepresentable {

    let onCaptured: (UIImage) -> Void
    var onCancel: (() -> Void)? = nil

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {

        let parent: OCRScannerView

        init(_ parent: OCRScannerView) {
            self.parent = parent
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else {
                controller.dismiss(animated: true)
                parent.onCancel?()
                return
            }
            let image = scan.imageOfPage(at: 0)
            parent.onCaptured(image)
            controller.dismiss(animated: true)
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
            parent.onCancel?()
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFailWithError error: Error) {
            controller.dismiss(animated: true)
            parent.onCancel?()
        }
    }
}
