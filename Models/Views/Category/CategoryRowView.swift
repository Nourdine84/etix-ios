import SwiftUI

struct CategoryRowView: View {

    let category: CategoryTotal
    let percent: Double

    private var deltaPercent: Double? {
        guard category.previousTotal > 0 else { return nil }
        return ((category.total - category.previousTotal) / category.previousTotal) * 100
    }

    var body: some View {
        NavigationLink {
            CategoryDetailView(categoryName: category.name)
        } label: {
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
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
