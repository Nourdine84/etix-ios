import Foundation
import Combine

final class HomeV2ViewModel: ObservableObject {

    @Published var totalAmount: Double = 0.0
    @Published var ticketsCount: Int = 0
    @Published var monthAmount: Double = 0.0

    init() {
        loadMockData()
    }

    func loadMockData() {
        // ⚠️ V2: sera branché plus tard à CoreData
        totalAmount = 1243.50
        ticketsCount = 42
        monthAmount = 312.90
    }
}
