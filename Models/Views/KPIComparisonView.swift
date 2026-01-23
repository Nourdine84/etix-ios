import SwiftUI

struct KPIComparisonView: View {

    let comparison: KPIComparison

    var body: some View {
        HStack(spacing: 8) {

            Image(systemName: comparison.isPositive ? "arrow.up.right" : "arrow.down.right")
                .foregroundColor(comparison.isPositive ? .green : .red)

            Text(comparisonText)
                .font(.subheadline)
                .foregroundColor(comparison.isPositive ? .green : .red)

            Spacer()
        }
        .padding()
        .background(
            (comparison.isPositive ? Color.green : Color.red)
                .opacity(0.08)
        )
        .cornerRadius(12)
    }

    private var comparisonText: String {
        let value = String(format: "%.1f", abs(comparison.deltaPercent))
        return "\(value) % vs \(comparison.label)"
    }
}
