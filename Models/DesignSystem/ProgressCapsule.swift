import SwiftUI

/// Barre de progression capsule 4pt — unifie les trois copies V1
/// (budgetBar de CategoryRowView, topCategories de StoreDetailView,
/// BudgetSummaryCardView).
struct ProgressCapsule: View {

    /// Progression 0...1 — les valeurs hors bornes sont clampées.
    let progress: Double
    var color: Color = Theme.primaryBlue
    var height: CGFloat = 4

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color(.systemFill))
                .frame(height: height)
            Capsule()
                .fill(color)
                .scaleEffect(x: min(max(progress, 0), 1), anchor: .leading)
                .frame(height: height)
        }
    }
}

#Preview("États") {
    VStack(spacing: 20) {
        ProgressCapsule(progress: 0.3)
        ProgressCapsule(progress: 0.85, color: .orange)
        ProgressCapsule(progress: 1.2, color: .red)
        ProgressCapsule(progress: 0.5, color: .green, height: 6)
    }
    .padding()
    .background(Theme.Background.primary)
}
