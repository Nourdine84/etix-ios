import SwiftUI

private enum BudgetStatus {
    case ok, warning, exceeded

    static func compute(ratio: Double) -> BudgetStatus {
        if ratio >= 1.0 { return .exceeded }
        if ratio >= 0.8 { return .warning }
        return .ok
    }

    var color: Color {
        switch self {
        case .ok:       return .green
        case .warning:  return .orange
        case .exceeded: return .red
        }
    }

    func statusLabel(ratio: Double) -> String? {
        switch self {
        case .ok:       return nil
        case .warning:  return String(format: "Attention — %.0f%%", ratio * 100)
        case .exceeded: return String(format: "Dépassé — %.0f%%", ratio * 100)
        }
    }
}

struct CategoryRowView: View {

    let category: CategoryTotal
    let percent: Double
    var budget: Double? = nil
    var range: TimeRange = .month

    private var deltaPercent: Double? {
        guard category.previousTotal > 0 else { return nil }
        return ((category.total - category.previousTotal) / category.previousTotal) * 100
    }

    private var budgetRatio: Double? {
        guard let limit = budget, limit > 0 else { return nil }
        return category.total / limit
    }

    var body: some View {
        NavigationLink {
            CategoryDetailView(categoryName: category.name, initialRange: range)
        } label: {
            VStack(alignment: .leading, spacing: 10) {

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .font(.headline)

                        HStack(spacing: 6) {
                            Text(String(format: "%.2f €", category.total))
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            if let delta = deltaPercent {
                                Text(String(format: "%+.0f%%", delta))
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(delta >= 0 ? .red : .green)
                            }
                        }
                    }

                    Spacer()

                    Text(String(format: "%.0f %%", percent))
                        .font(.subheadline.bold())
                        .foregroundColor(Theme.primaryBlue)
                }

                if let ratio = budgetRatio {
                    budgetBar(ratio: ratio)
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private func budgetBar(ratio: Double) -> some View {
        let status = BudgetStatus.compute(ratio: ratio)
        let limit = budget!

        return VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemFill))
                    .frame(height: 4)
                Capsule()
                    .fill(status.color)
                    .scaleEffect(x: min(ratio, 1.0), anchor: .leading)
                    .frame(height: 4)
            }

            HStack {
                if let label = status.statusLabel(ratio: ratio) {
                    Text(label)
                        .font(.caption2.weight(.medium))
                        .foregroundColor(status.color)
                }
                Spacer()
                Text(String(format: "%.0f € / %.0f €", category.total, limit))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}
