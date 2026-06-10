import Foundation

struct StoreTotal: Identifiable {

    let id: UUID
    let storeName: String?
    let total: Double
    let ticketCount: Int
    let lastPurchaseMillis: Int64

    init(
        id: UUID = UUID(),
        storeName: String?,
        total: Double,
        ticketCount: Int,
        lastPurchaseMillis: Int64 = 0
    ) {
        self.id = id
        self.storeName = storeName
        self.total = total
        self.ticketCount = ticketCount
        self.lastPurchaseMillis = lastPurchaseMillis
    }
}
