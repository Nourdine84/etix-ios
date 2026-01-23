import SwiftUI

struct KPIHeaderView: View {

    let title: String
    let total: Double
    let ticketCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)

            Text(String(format: "%.2f €", total))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(Color(Theme.primaryBlue))

            Text("\(ticketCount) ticket\(ticketCount > 1 ? "s" : "")")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .padding(.horizontal)
    }
}
