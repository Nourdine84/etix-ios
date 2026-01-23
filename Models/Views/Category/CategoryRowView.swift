import SwiftUI

struct CategoryRowView: View {

    let category: CategoryTotal
    let percent: Double

    var body: some View {
        NavigationLink {
            CategoryDetailView(categoryName: category.name)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.headline)

                    Text(String(format: "%.2f €", category.total))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(String(format: "%.0f %%", percent))
                    .font(.subheadline.bold())
                    .foregroundColor(Color(Theme.primaryBlue))
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
