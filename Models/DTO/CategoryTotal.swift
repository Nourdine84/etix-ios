import Foundation

struct CategoryTotal: Identifiable {
    let id = UUID()
    let name: String
    let total: Double
    var previousTotal: Double = 0
}
