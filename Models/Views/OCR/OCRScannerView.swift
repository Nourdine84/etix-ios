import SwiftUI
import VisionKit
import Vision

struct OCRScannerView: UIViewControllerRepresentable {

    let onScanResult: (OCRExtractedData) -> Void

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
                return
            }

            // Première page
            let img = scan.imageOfPage(at: 0)

            // Extraire texte avec Vision, puis parser (logique métier pure)
            extractText(from: img) { extractedText in
                let parsed = ReceiptParser.parse(extractedText)
                DispatchQueue.main.async {
                    self.parent.onScanResult(parsed)
                    controller.dismiss(animated: true)
                }
            }
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFailWithError error: Error) {
            controller.dismiss(animated: true)
        }

        // MARK: - Vision Text Recognition
        func extractText(from image: UIImage, completion: @escaping (String) -> Void) {

            guard let cgImage = image.cgImage else {
                completion("")
                return
            }

            let request = VNRecognizeTextRequest { request, error in
                if let results = request.results as? [VNRecognizedTextObservation] {
                    let extracted = results.compactMap {
                        $0.topCandidates(1).first?.string
                    }.joined(separator: "\n")

                    completion(extracted)
                } else {
                    completion("")
                }
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }

    }
}
