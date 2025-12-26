import Foundation
import Vision
import UIKit

final class OCRTextRecognizer {

    // MARK: - Public API
    static func recognizeText(
        from image: UIImage,
        completion: @escaping (OCRExtractedData) -> Void
    ) {
        guard let cgImage = image.cgImage else {
            completion(emptyResult)
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                completion(emptyResult)
                return
            }

            let observations = request.results as? [VNRecognizedTextObservation] ?? []

            // 🔤 Lignes OCR brutes
            let lines: [String] = observations.compactMap {
                $0.topCandidates(1).first?.string
            }

            // 🧠 Parsing centralisé
            let parsed = OCRParser.parse(lines: lines)

            completion(parsed)
        }

        // MARK: - Vision configuration
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["fr_FR"]

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion(emptyResult)
            }
        }
    }

    // MARK: - Helpers
    private static var emptyResult: OCRExtractedData {
        OCRExtractedData(
            storeName: nil,
            amount: nil,
            date: nil
        )
    }
}
