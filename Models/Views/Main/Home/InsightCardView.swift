import SwiftUI

struct InsightCardView: View {

    let insight: HomeInsight
    let isPrimary: Bool

    var body: some View {
        NavigationLink {
            resolvedDestination
        } label: {
            HStack(spacing: 14) {
                Image(systemName: insight.icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text(insight.title)
                        .font(isPrimary ? .subheadline.weight(.semibold) : .footnote.weight(.semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    Text(insight.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(isPrimary ? 20 : 16)
            .background(cardBackground)
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
        .onAppear {
            InsightMemory.markShown(insight.id)
        }
    }

    // MARK: - Destination

    @ViewBuilder
    private var resolvedDestination: some View {
        switch insight.destination {
        case .categoryDetail(let name):
            CategoryDetailView(categoryName: name, initialRange: .month)
        case .storeDetail(let name):
            StoreDetailView(storeName: name)
        case .monthlyReport:
            MonthlyReportView()
        }
    }

    // MARK: - Style

    private var iconColor: Color {
        switch insight.severity {
        case .critical: return .red
        case .warning:  return .orange
        case .neutral:  return Theme.primaryBlue
        }
    }

    private var cardBackground: Color {
        switch insight.severity {
        case .critical: return Color.red.opacity(0.08)
        case .warning:  return Color.orange.opacity(0.08)
        case .neutral:  return Color(.secondarySystemGroupedBackground)
        }
    }
}
