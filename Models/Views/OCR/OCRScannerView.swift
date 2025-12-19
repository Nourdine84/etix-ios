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

            // Extraire texte avec Vision
            extractText(from: img) { extractedText in
                let parsed = Self.parseText(extractedText)
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

        // MARK: - Parsing texte
        static func parseText(_ text: String) -> OCRExtractedData {

            let lines = text.lowercased().components(separatedBy: .newlines)

            // 🔵 1. Trouver le montant (ex: 12.50, 9,99, etc.)
            let amount = lines.compactMap { line -> Double? in
                let regex = try! NSRegularExpression(pattern: #"(\d+[.,]\d{2})"#)
                let matches = regex.matches(in: line, range: NSRange(line.startIndex..., in: line))

                if let match = matches.first,
                   let range = Range(match.range, in: line) {
                    let value = line[range].replacingOccurrences(of: ",", with: ".")
                    return Double(value)
                }
                return nil
            }.first

            // 🔵 2. Trouver la date (formats FR courants)
            let date = detectDate(in: lines)

            // 🔵 3. Trouver un magasin plausible
            let store = lines.first?.capitalized

            return OCRExtractedData(storeName: store,
                                    amount: amount,
                                    date: date)
        }

        static func detectDate(in lines: [String]) -> Date? {
            let formats = [
                "dd/MM/yyyy",
                "dd-MM-yyyy",
                "dd.MM.yyyy",
                "dd/MM/yy",
                "dd-MM-yy"
            ]

            for line in lines {
                for format in formats {
                    let df = DateFormatter()
                    df.locale = Locale(identifier: "fr_FR")
                    df.dateFormat = format

                    if let d = df.date(from: line.trimmingCharacters(in: .whitespaces)) {
                        return d
                    }
                }
            }
            return nil
        }
    }
}
