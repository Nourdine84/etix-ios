import SwiftUI

struct KPIPrimaryCard: View {

    let title: String
    let value: Double
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(format(value))
                .font(.system(size: 34, weight: .bold))

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [
                            Theme.primaryBlue.opacity(0.95),
                            Theme.primaryBlue.opacity(0.75)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .foregroundColor(.white)
        .shadow(color: Theme.primaryBlue.opacity(0.3), radius: 18, y: 10)
    }

    private func format(_ value: Double) -> String {
        String(format: "%.2f €", value)
    }
}
