import SwiftUI

struct CategoryRowView: View {

    let category: CategoryTotal
    let percent: Double

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(category.name)
                    .font(.headline)

                Text("\(percent, specifier: "%.1f") %")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("\(category.total, specifier: "%.2f") €")
                .bold()
                .foregroundColor(Color(Theme.primaryBlue))
        }
        .padding(.vertical, 6)
    }
}
