import Foundation

/// Agrégats partagés du HomeView — construit en un seul passage O(N) sur les tickets.
/// Consommé par HomeInsightEngine (Sprint 1), puis BudgetSummaryEngine et
/// StoreIntelligenceEngine dans les sprints suivants.
struct HomeSnapshot {

    // MARK: - Période courante
    let periodTotal: Double
    let periodTicketCount: Int

    // MARK: - Période précédente
    let previousPeriodTotal: Double

    // MARK: - Agrégats par catégorie (période courante, clé lowercased — aligné BudgetStore)
    let categoryTotals: [String: Double]
    /// Casse d'affichage : lowercased → casse du ticket le plus récent rencontré
    let categoryDisplayNames: [String: String]

    // MARK: - Agrégats par magasin (période courante, clé = storeName exact)
    let storeTotals: [String: Double]
    let storeTicketCounts: [String: Int]

    // MARK: - Global
    let allTimeTicketCount: Int
    let daysLeftInMonth: Int

    // MARK: - Init

    init(tickets: [Ticket], range: TimeRange, now: Date = Date()) {
        let current = DateRangeHelper.currentRange(for: range)
        let previous = DateRangeHelper.previousRange(for: range)
        let curStart = DateRangeHelper.millis(current.start)
        let curEnd = DateRangeHelper.millis(current.end)
        let prevStart = DateRangeHelper.millis(previous.start)
        let prevEnd = DateRangeHelper.millis(previous.end)

        var periodTotal: Double = 0
        var periodCount = 0
        var previousTotal: Double = 0
        var catTotals: [String: Double] = [:]
        var catNames: [String: String] = [:]
        var stTotals: [String: Double] = [:]
        var stCounts: [String: Int] = [:]

        for ticket in tickets {
            let ms = ticket.dateMillis

            if ms >= curStart && ms < curEnd {
                periodTotal += ticket.amount
                periodCount += 1

                let catKey = ticket.category.lowercased()
                if !catKey.isEmpty {
                    catTotals[catKey, default: 0] += ticket.amount
                    if catNames[catKey] == nil {
                        catNames[catKey] = ticket.category
                    }
                }

                stTotals[ticket.storeName, default: 0] += ticket.amount
                stCounts[ticket.storeName, default: 0] += 1

            } else if ms >= prevStart && ms < prevEnd {
                previousTotal += ticket.amount
            }
        }

        self.periodTotal = periodTotal
        self.periodTicketCount = periodCount
        self.previousPeriodTotal = previousTotal
        self.categoryTotals = catTotals
        self.categoryDisplayNames = catNames
        self.storeTotals = stTotals
        self.storeTicketCounts = stCounts
        self.allTimeTicketCount = tickets.count

        let calendar = Calendar.current
        let monthEnd = DateRangeHelper.currentRange(for: .month).end
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: now),
            to: monthEnd
        ).day ?? 0
        self.daysLeftInMonth = max(0, days)
    }
}
