import SwiftUI

struct KPIBarChartView: View {

    let data: [(date: Date, total: Double)]

    private let maxBars = 7

    var body: some View {
        let sliced = Array(data.prefix(maxBars))
        let maxValue = sliced.map(\.total).max() ?? 1

        VStack(alignment: .leading, spacing: 12) {
            Text("Évolution")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(sliced, id: \.date) { item in
                    VStack(spacing: 6) {
                        Capsule()
                            .fill(Color(Theme.primaryBlue))
                            .frame(
                                height: CGFloat(item.total / maxValue) * 120
                            )

                        Text(shortLabel(for: item.date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 140)
            .padding(.horizontal)
        }
    }

    private func shortLabel(for date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Auj." }
        if cal.isDateInYesterday(date) { return "Hier" }

        let f = DateFormatter()
        f.dateFormat = "dd/MM"
        return f.string(from: date)
    }
}
