import UIKit
import Vision

/// Reconnaissance de texte (Vision) exécutée **hors du main thread**.
///
/// Étape intermédiaire entre la capture (`OCRScannerView`, qui retourne une
/// image) et le parsing métier (`ReceiptParser`, qui reçoit du texte). Isolée
/// ici pour ne plus jamais bloquer l'interface pendant la reconnaissance.
enum TextRecognizer {

    /// Reconnaît le texte de l'image sur une file de fond, puis renvoie le
    /// résultat sur le main thread.
    static func recognize(_ image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("")
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            try? VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])

            let text = (request.results as? [VNRecognizedTextObservation])?
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n") ?? ""

            DispatchQueue.main.async {
                completion(text)
            }
        }
    }
}
