import Foundation

struct KPIComparison {
    let deltaPercent: Double
    let isPositive: Bool
    let label: String

    static func compute(current: Double, previous: Double, label: String) -> KPIComparison {
        guard previous > 0 else {
            return KPIComparison(
                deltaPercent: 0,
                isPositive: true,
                label: label
            )
        }

        let delta = ((current - previous) / previous) * 100

        return KPIComparison(
            deltaPercent: delta,
            isPositive: delta >= 0,
            label: label
        )
    }
}
