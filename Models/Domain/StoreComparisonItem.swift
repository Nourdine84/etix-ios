import Foundation

struct StoreComparisonItem: Identifiable {
    let id = UUID()
    let storeName: String
    let total: Double
    let ticketCount: Int
    let sharePercent: Double
}
