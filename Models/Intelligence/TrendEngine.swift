import Foundation

// MARK: - Modèle

struct MonthlyTrendPoint: Identifiable, Equatable {
    let month: String      // libellé court FR ("JANV", "FÉVR", …)
    let total: Double

    var id: String { month }
}

// MARK: - Moteur

/// Moteur pur — agrège les dépenses par mois calendaire sur les 6 derniers mois
/// (mois courant inclus), en un seul passage O(N) sur les tickets.
/// Les mois sans activité sont présents avec un total de 0 pour garder la
/// continuité de la courbe.
struct TrendEngine {

    static func monthlyTrend(
        tickets: [Ticket],
        monthsBack: Int = 6,
        now: Date = Date()
    ) -> [MonthlyTrendPoint] {

        let calendar = Calendar.current
        guard monthsBack > 0,
              let currentMonthStart = calendar.date(
                from: calendar.dateComponents([.year, .month], from: now)
              ),
              let upperBound = calendar.date(byAdding: .month, value: 1, to: currentMonthStart)
        else { return [] }

        // Bornes des buckets en millis, du plus ancien au plus récent
        var starts: [Date] = []
        for offset in stride(from: monthsBack - 1, through: 0, by: -1) {
            guard let d = calendar.date(byAdding: .month, value: -offset, to: currentMonthStart)
            else { return [] }
            starts.append(d)
        }
        let boundaries = starts.map { Int64($0.timeIntervalSince1970 * 1000) }
            + [Int64(upperBound.timeIntervalSince1970 * 1000)]

        var totals = [Double](repeating: 0, count: monthsBack)
        for ticket in tickets {
            let ms = ticket.dateMillis
            guard ms >= boundaries[0], ms < boundaries[monthsBack] else { continue }
            // 6 buckets max — la recherche linéaire reste O(1)
            for i in 0..<monthsBack where ms < boundaries[i + 1] {
                totals[i] += ticket.amount
                break
            }
        }

        let df = DateFormatter()
        df.locale = Locale(identifier: "fr_FR")
        let symbols = df.shortStandaloneMonthSymbols ?? df.shortMonthSymbols ?? []

        return starts.enumerated().map { i, start in
            let monthIndex = calendar.component(.month, from: start) - 1
            let raw = monthIndex < symbols.count ? symbols[monthIndex] : "\(monthIndex + 1)"
            let label = raw.replacingOccurrences(of: ".", with: "").uppercased()
            return MonthlyTrendPoint(month: label, total: totals[i])
        }
    }
}
