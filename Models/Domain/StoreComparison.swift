import Foundation

struct StoreComparison: Identifiable {
    let id = UUID()
    let rank: Int
    let storeName: String
    let total: Double
    let percent: Double
    let ticketCount: Int
}
