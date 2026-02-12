import SwiftUI

struct KPISmallCard: View {

    let title: String
    let value: Double
    let unit: String

    var body: some View {
        VStack(spacing: 6) {

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(formatted)
                .font(.headline)

        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private var formatted: String {
        if unit.isEmpty {
            return "\(Int(value))"
        }
        return String(format: "%.2f %@", value, unit)
    }
}
