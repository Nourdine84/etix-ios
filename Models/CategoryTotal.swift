import Foundation

struct CategoryTotal: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let total: Double
}
