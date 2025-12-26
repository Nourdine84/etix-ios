import WidgetKit
import SwiftUI

private let suiteID = "group.etix.shared"

// MARK: - Entry
struct ETixEntry: TimelineEntry {
    let date: Date
    let monthLabel: String
    let total: Double
    let count: Int
}

// MARK: - Provider
struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> ETixEntry {
        ETixEntry(date: .now, monthLabel: "— ———", total: 123.45, count: 5)
    }

    func getSnapshot(in context: Context, completion: @escaping (ETixEntry) -> Void) {
        completion(loadSnapshot())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ETixEntry>) -> Void) {
        let entry = loadSnapshot()
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func loadSnapshot() -> ETixEntry {
        let ud = UserDefaults(suiteName: suiteID)

        return ETixEntry(
            date: .now,
            monthLabel: ud?.string(forKey: "monthLabel") ?? formattedMonth(Date()),
            total: ud?.double(forKey: "monthTotal") ?? 0,
            count: ud?.integer(forKey: "monthCount") ?? 0
        )
    }

    private func formattedMonth(_ date: Date) -> String {
        let df = DateFormatter()
        df.locale = .current
        df.setLocalizedDateFormatFromTemplate("MMM yyyy")
        return df.string(from: date).capitalized
    }
}

// MARK: - Widget View
struct ETixWidgetView: View {
    let entry: ETixEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chart.bar.fill")
                Spacer()
                Text(entry.monthLabel)
                    .font(.caption)
            }

            Spacer()

            Text(String(format: "%.2f €", entry.total))
                .font(.system(size: 24, weight: .bold))

            Text("\(entry.count) ticket\(entry.count > 1 ? "s" : "")")
                .font(.footnote)
        }
        .foregroundColor(.white)
        .padding()
        // ✅ FIX CRITIQUE ICI
        .containerBackground(
            LinearGradient(
                colors: [
                    Color(Theme.primaryBlue),
                    Color(Theme.primaryBlue).opacity(0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            for: .widget
        )
    }
}

// MARK: - Widget declaration
@main
struct eTixWidget: Widget {
    let kind = "eTixWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ETixWidgetView(entry: entry)
        }
        .configurationDisplayName("Dépenses du mois")
        .description("Affiche le total du mois et le nombre de tickets.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    eTixWidget()
} timeline: {
    ETixEntry(date: .now, monthLabel: "Déc. 2025", total: 256.50, count: 9)
}
