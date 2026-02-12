import SwiftUI

// MARK: - Slice Model (Catégorie ONLY)
struct CategoryDonutSlice: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let color: Color
}

// MARK: - Donut View
struct CategoryDonutView: View {

    let categories: [CategoryTotal]
    let total: Double

    private var slices: [CategoryDonutSlice] {
        categories.enumerated().map { index, cat in
            CategoryDonutSlice(
                label: cat.name,
                value: cat.total,
                color: palette[index % palette.count]
            )
        }
    }

    var body: some View {
        VStack(spacing: 16) {

            ZStack {
                ForEach(slices.indices, id: \.self) { index in
                    CategoryDonutSliceView(
                        slice: slices[index],
                        startAngle: startAngle(for: index),
                        endAngle: endAngle(for: index)
                    )
                }

                VStack {
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(String(format: "%.2f €", total))
                        .font(.headline.bold())
                }
            }
            .frame(width: 220, height: 220)

            // Légende
            VStack(alignment: .leading, spacing: 8) {
                ForEach(slices) { slice in
                    HStack {
                        Circle()
                            .fill(slice.color)
                            .frame(width: 10, height: 10)

                        Text(slice.label)
                            .font(.caption)

                        Spacer()

                        Text(String(format: "%.1f %%", percentage(of: slice)))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    // MARK: - Angles
    private func startAngle(for index: Int) -> Double {
        let sum = slices.prefix(index).reduce(0) { $0 + $1.value }
        return angle(for: sum)
    }

    private func endAngle(for index: Int) -> Double {
        let sum = slices.prefix(index + 1).reduce(0) { $0 + $1.value }
        return angle(for: sum)
    }

    private func angle(for value: Double) -> Double {
        guard total > 0 else { return 0 }
        return (value / total) * 360
    }

    private func percentage(of slice: CategoryDonutSlice) -> Double {
        guard total > 0 else { return 0 }
        return (slice.value / total) * 100
    }

    // MARK: - Palette
    private let palette: [Color] = [
        .blue, .green, .orange, .purple, .pink, .red, .teal
    ]
}

// MARK: - Slice Shape View
struct CategoryDonutSliceView: View {

    let slice: CategoryDonutSlice
    let startAngle: Double
    let endAngle: Double

    var body: some View {
        Circle()
            .trim(
                from: startAngle / 360,
                to: endAngle / 360
            )
            .stroke(
                slice.color,
                style: StrokeStyle(lineWidth: 40, lineCap: .butt)
            )
            .rotationEffect(.degrees(-90))
    }
}
