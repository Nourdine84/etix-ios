import SwiftUI

struct BudgetSummaryCardView: View {

    let summary: BudgetSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("BUDGETS DU MOIS")
                .font(.caption2)
                .tracking(1)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text(headline)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(summary.state == .exceeded ? .red : .primary)
                Text("\(euros(summary.totalSpent)) dépensés sur \(euros(summary.totalBudget)) prévus")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Barre de progression globale
            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemFill))
                        .frame(height: 6)
                    Capsule()
                        .fill(barColor(summary.state))
                        .scaleEffect(x: min(summary.globalRatio, 1.0), anchor: .leading)
                        .frame(height: 6)
                }
                HStack {
                    Text("\(Int(summary.globalRatio * 100))%")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(barColor(summary.state))
                    Spacer()
                    Text("\(summary.daysLeftInMonth) jour\(summary.daysLeftInMonth > 1 ? "s" : "") restant\(summary.daysLeftInMonth > 1 ? "s" : "") dans le mois")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            if !summary.lines.isEmpty {
                Divider()

                VStack(spacing: 8) {
                    ForEach(summary.lines) { line in
                        budgetLineRow(line)
                    }
                }

                if summary.extraCount > 0 {
                    Text("et \(summary.extraCount) autre\(summary.extraCount > 1 ? "s" : "") →")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(cardBackground)
        .cornerRadius(20)
    }

    // MARK: - Ligne par catégorie

    private func budgetLineRow(_ line: BudgetLine) -> some View {
        HStack(spacing: 8) {
            Text(line.categoryName)
                .font(.caption)
                .lineLimit(1)
                .frame(width: 90, alignment: .leading)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemFill))
                    .frame(height: 4)
                Capsule()
                    .fill(barColor(line.state))
                    .scaleEffect(x: min(line.ratio, 1.0), anchor: .leading)
                    .frame(height: 4)
            }
            Text("\(Int(line.ratio * 100))%")
                .font(.caption2.weight(.semibold))
                .foregroundColor(barColor(line.state))
                .frame(width: 40, alignment: .trailing)
        }
    }

    // MARK: - Style

    private var headline: String {
        summary.state == .exceeded
            ? "Budgets dépassés de \(euros(-summary.remaining))"
            : "Il te reste \(euros(summary.remaining))"
    }

    private var cardBackground: Color {
        switch summary.state {
        case .comfortable: return Color(.secondarySystemGroupedBackground)
        case .caution:     return Color.orange.opacity(0.08)
        case .critical, .exceeded: return Color.red.opacity(0.08)
        }
    }

    private func barColor(_ state: BudgetState) -> Color {
        switch state {
        case .comfortable: return Theme.primaryBlue
        case .caution:     return .orange
        case .critical, .exceeded: return .red
        }
    }

    private func euros(_ value: Double) -> String {
        String(format: "%.0f €", value)
    }
}
