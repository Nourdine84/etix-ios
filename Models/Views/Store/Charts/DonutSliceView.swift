import SwiftUI

struct DonutSliceView: View {

    let slice: DonutSlice

    var body: some View {
        Circle()
            .trim(
                from: max(0, min(slice.startAngle, 1)),
                to: max(0, min(slice.endAngle, 1))
            )
            .stroke(
                color(for: slice.id),
                style: StrokeStyle(
                    lineWidth: 26,
                    lineCap: .butt
                )
            )
            .rotationEffect(.degrees(-90))
    }

    private func color(for id: UUID) -> Color {
        let colors: [Color] = [
            .blue,
            .green,
            .orange,
            .purple,
            .pink,
            .teal
        ]

        return colors[
            abs(id.hashValue) % colors.count
        ]
    }
}
