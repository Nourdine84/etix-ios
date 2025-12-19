import Foundation

struct MonthlyStat: Identifiable, Hashable {
    let id = UUID()
    let monthKey: String      // "2025-10"
    let monthLabel: String    // "Oct. 2025"
    let totalAmount: Double
    let ticketCount: Int
}
