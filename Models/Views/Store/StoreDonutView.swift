import SwiftUI

struct StoreDonutSlice: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let color: Color
}

struct StoreDonutView: View {

    let items: [StoreComparisonItem]
    let total: Double

    private var slices: [StoreDonutSlice] {
        items.enumerated().map { index, item in
            StoreDonutSlice(
                label: item.storeName,
                value: item.total,
                color: palette[index % palette.count]
            )
        }
    }

    var body: some View {
        VStack(spacing: 16) {

            ZStack {
                ForEach(slices.indices, id: \.self) { index in
                    StoreDonutSliceView(
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
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

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

    private let palette: [Color] = [
        .blue, .green, .orange, .purple, .pink, .red, .teal
    ]
}

struct StoreDonutSliceView: View {

    let slice: StoreDonutSlice
    let startAngle: Double
    let endAngle: Double

    var body: some View {
        Circle()
            .trim(from: startAngle / 360, to: endAngle / 360)
            .stroke(slice.color, style: StrokeStyle(lineWidth: 40))
            .rotationEffect(.degrees(-90))
    }
}
