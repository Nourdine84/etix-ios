import SwiftUI

struct KPIPrimaryCard: View {

    let title: String
    let value: Double
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(format(value))
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(18)
    }

    private func format(_ v: Double) -> String {
        String(format: "%.2f €", v)
    }
}
