import Foundation

struct OCRExtractedData: Identifiable, Equatable {
    let id = UUID()

    let storeName: String?
    let amount: Double?
    let date: Date?

    // 🔐 Score de confiance (0 → 1)
    let confidence: Double

    // MARK: - Init standard
    init(
        storeName: String?,
        amount: Double?,
        date: Date?,
        confidence: Double = 0.0
    ) {
        self.storeName = storeName
        self.amount = amount
        self.date = date
        self.confidence = confidence
    }

    // MARK: - Helpers
    var isReliable: Bool {
        confidence >= 0.6
    }

    // MARK: - Equatable (requis pour SwiftUI onChange / sheet)
    static func == (lhs: OCRExtractedData, rhs: OCRExtractedData) -> Bool {
        lhs.id == rhs.id
    }
}
