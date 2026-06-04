import SwiftUI

struct KPISmallCard: View {

    let title: String
    let value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(format(value))
                .font(.title3.bold())
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 10, y: 6)
        )
    }

    private func format(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}
