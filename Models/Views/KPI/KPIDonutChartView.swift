import SwiftUI

struct KPIDonutChartView: View {

    struct Slice: Identifiable {
        let id = UUID()
        let name: String
        let value: Double
        let color: Color
    }

    let slices: [Slice]
    let total: Double

    var body: some View {
        VStack(spacing: 16) {

            Text("Répartition par catégorie")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            ZStack {
                // Donut
                ForEach(Array(slices.enumerated()), id: \.element.id) { index, slice in
                    Circle()
                        .trim(
                            from: startAngle(for: index),
                            to: endAngle(for: index)
                        )
                        .stroke(
                            slice.color,
                            style: StrokeStyle(lineWidth: 22, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                }

                // Total au centre
                VStack(spacing: 4) {
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(String(format: "%.2f €", total))
                        .font(.headline)
                        .foregroundColor(Color(Theme.primaryBlue))
                }
            }
            .frame(width: 180, height: 180)

            // Légende
            VStack(spacing: 8) {
                ForEach(slices) { slice in
                    HStack {
                        Circle()
                            .fill(slice.color)
                            .frame(width: 10, height: 10)

                        Text(slice.name)
                            .font(.subheadline)

                        Spacer()

                        Text(String(format: "%.2f €", slice.value))
                            .font(.subheadline.weight(.semibold))
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Angles helpers

    private func startAngle(for index: Int) -> CGFloat {
        let sum = slices.prefix(index).reduce(0) { $0 + $1.value }
        return CGFloat(sum / total)
    }

    private func endAngle(for index: Int) -> CGFloat {
        let sum = slices.prefix(index + 1).reduce(0) { $0 + $1.value }
        return CGFloat(sum / total)
    }
}
