import SwiftUI

struct KPIHeaderView: View {

    let title: String
    let total: Double
    let ticketCount: Int
    let variation: Double

    private var variationColor: Color {
        variation >= 0 ? .green : .red
    }

    private var variationText: String {
        let sign = variation >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", variation)) %"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)

            Text(String(format: "%.2f €", total))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color(Theme.primaryBlue))

            HStack(spacing: 12) {
                Text("\(ticketCount) ticket\(ticketCount > 1 ? "s" : "")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(variationText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(variationColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
