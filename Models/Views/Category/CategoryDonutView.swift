import SwiftUI

struct CategoryDonutView: View {

    let categories: [CategoryTotal]
    let total: Double

    var body: some View {
        ZStack {
            ForEach(Array(categories.enumerated()), id: \.offset) { index, cat in
                Circle()
                    .trim(
                        from: startAngle(for: index),
                        to: endAngle(for: index)
                    )
                    .stroke(
                        Color(Theme.primaryBlue).opacity(Double(index + 1) / Double(categories.count + 1)),
                        lineWidth: 24
                    )
                    .rotationEffect(.degrees(-90))
            }

            VStack {
                Text("Total")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("\(total, specifier: "%.2f") €")
                    .font(.headline)
            }
        }
        .frame(height: 220)
    }

    private func startAngle(for index: Int) -> CGFloat {
        let previous = categories.prefix(index).reduce(0) { $0 + $1.total }
        return total == 0 ? 0 : previous / total
    }

    private func endAngle(for index: Int) -> CGFloat {
        let current = categories.prefix(index + 1).reduce(0) { $0 + $1.total }
        return total == 0 ? 0 : current / total
    }
}
