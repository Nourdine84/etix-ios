import Foundation

struct StoreComparison: Identifiable {
    let id = UUID()
    let storeName: String
    let total: Double
    let ticketCount: Int
}
