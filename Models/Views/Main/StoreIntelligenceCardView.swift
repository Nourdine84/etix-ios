import SwiftUI

struct StoreIntelligenceCardView: View {

    let intelligence: StoreIntelligence

    var body: some View {
        NavigationLink {
            StoreDetailView(storeName: intelligence.storeName)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: intelligence.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 3) {
                    Text(intelligence.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text(intelligence.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(cardBackground)
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }

    private var iconColor: Color {
        switch intelligence.kind {
        case .spendingSpike:  return .orange
        case .dominantStore:  return Theme.primaryBlue
        case .absentRegular:  return .secondary
        case .newMerchant:    return .green
        }
    }

    private var cardBackground: Color {
        switch intelligence.kind {
        case .spendingSpike:  return Color.orange.opacity(0.08)
        case .dominantStore:  return Color(.secondarySystemGroupedBackground)
        case .absentRegular:  return Color(.secondarySystemGroupedBackground)
        case .newMerchant:    return Color.green.opacity(0.08)
        }
    }
}
