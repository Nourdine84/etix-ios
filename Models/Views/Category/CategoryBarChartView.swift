import SwiftUI

struct CategoryBarChartView: View {

    let data: [(date: Date, total: Double)]

    private var maxValue: Double {
        data.map { $0.total }.max() ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Évolution journalière")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(data, id: \.date) { item in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(Theme.primaryBlue))
                            .frame(
                                width: 22,
                                height: CGFloat(item.total / maxValue) * 120
                            )

                        Text(dayLabel(item.date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private func dayLabel(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd/MM"
        return df.string(from: date)
    }
}
