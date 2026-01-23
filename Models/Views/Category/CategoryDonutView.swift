import SwiftUI

struct CategoryDonutView: View {

    let categories: [CategoryTotal]
    let total: Double

    private func percent(for cat: CategoryTotal) -> Double {
        guard total > 0 else { return 0 }
        return cat.total / total
    }

    var body: some View {
        VStack(spacing: 16) {

            Text("Répartition des dépenses")
                .font(.headline)

            ZStack {
                ForEach(Array(categories.enumerated()), id: \.element.id) { index, cat in
                    DonutSlice(
                        startAngle: startAngle(index),
                        endAngle: endAngle(index),
                        color: color(for: index)
                    )
                }

                VStack {
                    Text(String(format: "%.2f €", total))
                        .font(.title2.bold())
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 220, height: 220)
        }
    }

    // MARK: - Angles
    private func startAngle(_ index: Int) -> Angle {
        let sum = categories.prefix(index).reduce(0) { $0 + percent(for: $1) }
        return .degrees(sum * 360)
    }

    private func endAngle(_ index: Int) -> Angle {
        let sum = categories.prefix(index + 1).reduce(0) { $0 + percent(for: $1) }
        return .degrees(sum * 360)
    }

    private func color(for index: Int) -> Color {
        let palette: [Color] = [
            .blue, .green, .orange, .purple, .pink, .teal, .red
        ]
        return palette[index % palette.count]
    }
}

// MARK: - Slice
private struct DonutSlice: View {

    let startAngle: Angle
    let endAngle: Angle
    let color: Color

    var body: some View {
        Circle()
            .trim(from: startAngle.degrees / 360, to: endAngle.degrees / 360)
            .stroke(color, style: StrokeStyle(lineWidth: 36))
            .rotationEffect(.degrees(-90))
    }
}
