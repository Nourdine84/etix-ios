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

    // MARK: - Agrégats par magasin (période précédente & all-time, pour StoreIntelligenceEngine)
    let storePreviousTotals: [String: Double]
    let storeAllTimeCounts: [String: Int]
    let storeLastVisitMillis: [String: Int64]
    let storeOldestMillis: [String: Int64]

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
        var stPrevTotals: [String: Double] = [:]
        var stAllTimeCounts: [String: Int] = [:]
        var stLastVisit: [String: Int64] = [:]
        var stOldest: [String: Int64] = [:]

        for ticket in tickets {
            let ms = ticket.dateMillis
            let store = ticket.storeName

            // All-time store aggregates
            stAllTimeCounts[store, default: 0] += 1
            if ms > (stLastVisit[store] ?? Int64.min) { stLastVisit[store] = ms }
            if ms < (stOldest[store] ?? Int64.max)    { stOldest[store] = ms }

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

                stTotals[store, default: 0] += ticket.amount
                stCounts[store, default: 0] += 1

            } else if ms >= prevStart && ms < prevEnd {
                previousTotal += ticket.amount
                stPrevTotals[store, default: 0] += ticket.amount
            }
        }

        self.periodTotal = periodTotal
        self.periodTicketCount = periodCount
        self.previousPeriodTotal = previousTotal
        self.categoryTotals = catTotals
        self.categoryDisplayNames = catNames
        self.storeTotals = stTotals
        self.storeTicketCounts = stCounts
        self.storePreviousTotals = stPrevTotals
        self.storeAllTimeCounts = stAllTimeCounts
        self.storeLastVisitMillis = stLastVisit
        self.storeOldestMillis = stOldest
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
