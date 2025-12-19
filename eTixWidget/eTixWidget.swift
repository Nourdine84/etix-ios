import WidgetKit
import SwiftUI

// App Group — même ID que dans l’app
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
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    // Lecture AppGroup
    private func loadSnapshot() -> ETixEntry {
        let ud = UserDefaults(suiteName: suiteID)

        let total = ud?.double(forKey: "monthTotal") ?? 0
        let count = ud?.integer(forKey: "monthCount") ?? 0
        let label = ud?.string(forKey: "monthLabel") ?? formattedMonth(Date())

        return ETixEntry(date: .now, monthLabel: label, total: total, count: count)
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
        ZStack {
            LinearGradient(
                colors: [
                    Color(Theme.primaryBlue),
                    Color(Theme.primaryBlue).opacity(0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 6) {
                // Header
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(.white.opacity(0.95))
                    Spacer()
                    Text(entry.monthLabel)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Spacer(minLength: 4)

                // Total €
                Text(String(format: "%.2f €", entry.total))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Tickets
                Text("\(entry.count) ticket\(entry.count > 1 ? "s" : "")")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(14)
        }
    }
}

// MARK: - Declaration
@main
struct eTixWidget: Widget {
    let kind: String = "eTixWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ETixWidgetView(entry: entry)
        }
        .configurationDisplayName("Dépenses du mois")
        .description("Affiche le total du mois en cours et le nombre de tickets.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    eTixWidget()
} timeline: {
    ETixEntry(date: .now, monthLabel: "Déc. 2025", total: 256.50, count: 9)
}
