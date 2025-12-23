import SwiftUI

struct CategoryRowView: View {

    let category: Category
    var archived: Bool = false

    var body: some View {
        HStack(spacing: 12) {

            Image(systemName: category.icon ?? "square.grid.2x2")
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 28)

            Text(category.name ?? "Sans nom")
                .font(.body)

            Spacer()

            if archived {
                Text("Archivée")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }

    private var iconColor: Color {
        if let hex = category.colorHex {
            return Color(hex)
        }
        return Color(Theme.primaryBlue)
    }
}
