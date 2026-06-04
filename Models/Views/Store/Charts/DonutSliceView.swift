import SwiftUI

struct DonutSliceView: View {

    let slice: DonutSlice

    @State private var animatedEnd: Double = 0

    var body: some View {

        Circle()
            .trim(
                from: slice.startAngle,
                to: animatedEnd
            )
            .stroke(
                color(for: slice.id),
                style: StrokeStyle(
                    lineWidth: 28,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(-90))
            .onAppear {
                withAnimation(.easeOut(duration: 0.7)) {
                    animatedEnd = slice.endAngle
                }
            }
    }

    private func color(for id: UUID) -> Color {
        let colors: [Color] = [
            Theme.primaryBlue,
            .green,
            .orange,
            .purple,
            .pink,
            .teal
        ]
        return colors[abs(id.hashValue) % colors.count]
    }
}
