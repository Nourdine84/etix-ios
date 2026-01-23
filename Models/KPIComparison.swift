import Foundation

struct KPIComparison {
    let label: String
    let deltaPercent: Double

    var isPositive: Bool {
        deltaPercent >= 0
    }
}
