import Foundation

struct StoreTotal: Identifiable {

    let id: UUID
    let storeName: String?
    let total: Double
    let ticketCount: Int

    init(
        id: UUID = UUID(),
        storeName: String?,
        total: Double,
        ticketCount: Int
    ) {
        self.id = id
        self.storeName = storeName
        self.total = total
        self.ticketCount = ticketCount
    }
}
