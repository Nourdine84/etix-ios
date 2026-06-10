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
            let lines = text.components(separatedBy: .newlines)
            let lowered = lines.map { $0.lowercased() }

            return OCRExtractedData(
                storeName: extractStoreName(from: lines),
                amount:    extractAmount(from: lowered),
                date:      detectDate(in: lowered)
            )
        }

        // Cherche un montant en priorité sur les lignes "TOTAL / À PAYER / MONTANT"
        static func extractAmount(from loweredLines: [String]) -> Double? {
            let totalKeywords = ["total", "a payer", "à payer", "net", "montant ttc", "ttc"]

            for line in loweredLines where totalKeywords.contains(where: { line.contains($0) }) {
                if let amount = amountIn(line) { return amount }
            }
            for line in loweredLines {
                if let amount = amountIn(line) { return amount }
            }
            return nil
        }

        private static func amountIn(_ line: String) -> Double? {
            let regex = try! NSRegularExpression(pattern: #"(\d+[.,]\d{2})"#)
            guard let match = regex.matches(in: line, range: NSRange(line.startIndex..., in: line)).first,
                  let range = Range(match.range, in: line) else { return nil }
            return Double(line[range].replacingOccurrences(of: ",", with: "."))
        }

        // Cherche le premier nom de magasin plausible dans les 5 premières lignes
        static func extractStoreName(from lines: [String]) -> String? {
            for line in lines.prefix(5) {
                let t = line.trimmingCharacters(in: .whitespaces)
                guard t.count >= 3 else { continue }
                guard !t.allSatisfy({ $0.isNumber || " ./-".contains($0) }) else { continue }
                guard !isDateLike(t) else { continue }
                let lower = t.lowercased()
                guard !lower.hasPrefix("ticket") && !lower.hasPrefix("n°")
                        && !lower.hasPrefix("facture") && !lower.hasPrefix("recu") else { continue }
                return t.capitalized
            }
            return lines.first?.trimmingCharacters(in: .whitespaces).capitalized
        }

        private static func isDateLike(_ s: String) -> Bool {
            let pattern = #"\d{2}[/\-\.]\d{2}[/\-\.]\d{2,4}"#
            return (try? NSRegularExpression(pattern: pattern))?
                .firstMatch(in: s, range: NSRange(s.startIndex..., in: s)) != nil
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
