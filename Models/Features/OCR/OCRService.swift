import Vision
import UIKit

enum OCRService {

    static func recognizeText(
        from image: UIImage,
        completion: @escaping (OCRExtractedData?) -> Void
    ) {

        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("❌ OCR error:", error.localizedDescription)
                completion(nil)
                return
            }

            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let fullText = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")

            completion(parse(text: fullText))
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["fr-FR"]

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("❌ OCR handler error:", error.localizedDescription)
                completion(nil)
            }
        }
    }

    // MARK: - Parsing basique (V2)
    private static func parse(text: String) -> OCRExtractedData {

        var storeName: String?
        var amount: Double?
        var date: Date?

        let lines = text.components(separatedBy: .newlines)

        // 🏪 Magasin = première ligne "lisible"
        storeName = lines.first { $0.count > 3 }

        // 💰 Montant
        for line in lines {
            let cleaned = line
                .replacingOccurrences(of: ",", with: ".")
                .replacingOccurrences(of: "€", with: "")
                .trimmingCharacters(in: .whitespaces)

            if let value = Double(cleaned), value < 10_000 {
                amount = value
                break
            }
        }

        // 📅 Date simple (dd/MM/yyyy)
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"

        for line in lines {
            if let d = df.date(from: line) {
                date = d
                break
            }
        }

        return OCRExtractedData(
            storeName: storeName,
            amount: amount,
            date: date
        )
    }
}
