import SwiftUI

struct KPIComparisonView: View {
    let comparison: KPIComparison

    var body: some View {
        HStack {
            Image(systemName: comparison.isPositive ? "arrow.up.right" : "arrow.down.right")
            Text(String(format: "%.1f%% %@", abs(comparison.deltaPercent), comparison.label))
        }
        .font(.subheadline.weight(.semibold))
        .foregroundColor(comparison.isPositive ? .green : .red)
    }
}
