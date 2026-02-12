import SwiftUI

struct DonutSlice: Identifiable {

    let id: UUID
    let label: String
    let value: Double
    let startAngle: Double
    let endAngle: Double

    init(
        id: UUID = UUID(),
        label: String,
        value: Double,
        startAngle: Double,
        endAngle: Double
    ) {
        self.id = id
        self.label = label
        self.value = value
        self.startAngle = startAngle
        self.endAngle = endAngle
    }
}
