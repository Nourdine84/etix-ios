import Foundation

// MARK: - Modèle

enum StoreIntelligenceKind: Int, Comparable {
    case spendingSpike  = 1
    case dominantStore  = 2
    case absentRegular  = 3
    case newMerchant    = 4

    static func < (lhs: StoreIntelligenceKind, rhs: StoreIntelligenceKind) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct StoreIntelligence {
    let kind: StoreIntelligenceKind
    let storeName: String
    let title: String
    let subtitle: String
    let icon: String
}

// MARK: - Moteur

struct StoreIntelligenceEngine {

    static func evaluate(
        snapshot: HomeSnapshot,
        range: TimeRange,
        now: Date = Date()
    ) -> StoreIntelligence? {

        guard snapshot.allTimeTicketCount >= 3 else { return nil }

        var candidates: [StoreIntelligence] = []

        if let s = spendingSpike(snapshot: snapshot, range: range) { candidates.append(s) }
        if let s = dominantStore(snapshot: snapshot, range: range) { candidates.append(s) }
        if let s = absentRegular(snapshot: snapshot, range: range, now: now) { candidates.append(s) }
        if let s = newMerchant(snapshot: snapshot, now: now) { candidates.append(s) }

        return candidates.min { $0.kind < $1.kind }
    }

    // MARK: - Règle 1 : Pic de dépense (+40% vs période précédente)

    private static func spendingSpike(
        snapshot: HomeSnapshot,
        range: TimeRange
    ) -> StoreIntelligence? {
        guard range != .today else { return nil }

        var best: (store: String, gap: Double, current: Double, previous: Double)?
        for (store, current) in snapshot.storeTotals {
            let previous = snapshot.storePreviousTotals[store] ?? 0
            guard previous > 0, current > previous * 1.40 else { continue }
            let count = snapshot.storeTicketCounts[store] ?? 0
            guard count >= 2 else { continue }
            let gap = current - previous
            if gap > (best?.gap ?? 0) { best = (store, gap, current, previous) }
        }
        guard let b = best else { return nil }

        let deltaPercent = Int(((b.current - b.previous) / b.previous) * 100)
        return StoreIntelligence(
            kind: .spendingSpike,
            storeName: b.store,
            title: "\(b.store) : +\(deltaPercent)% vs période précédente",
            subtitle: "\(euros(b.current)) ce mois vs \(euros(b.previous))",
            icon: "arrow.up.right.circle.fill"
        )
    }

    // MARK: - Règle 2 : Magasin dominant (35–80%)

    private static func dominantStore(
        snapshot: HomeSnapshot,
        range: TimeRange
    ) -> StoreIntelligence? {
        guard range != .today, snapshot.periodTotal > 0 else { return nil }

        guard let (store, total) = snapshot.storeTotals.max(by: { $0.value < $1.value })
        else { return nil }

        let share = total / snapshot.periodTotal
        let count = snapshot.storeTicketCounts[store] ?? 0
        guard share >= 0.35, share <= 0.80, count >= 3 else { return nil }

        return StoreIntelligence(
            kind: .dominantStore,
            storeName: store,
            title: "\(store) représente \(Int(share * 100))% de tes dépenses",
            subtitle: "\(count) passage\(count > 1 ? "s" : "") · \(euros(total))",
            icon: "building.2.fill"
        )
    }

    // MARK: - Règle 3 : Régulier absent (intervalle moyen × 2 dépassé)

    private static func absentRegular(
        snapshot: HomeSnapshot,
        range: TimeRange,
        now: Date
    ) -> StoreIntelligence? {
        guard range != .today else { return nil }

        let nowMs = Int64(now.timeIntervalSince1970 * 1000)

        var best: (store: String, daysSince: Int, avgDays: Int)?
        for (store, allTimeCount) in snapshot.storeAllTimeCounts {
            guard allTimeCount >= 3 else { continue }
            guard let lastMs = snapshot.storeLastVisitMillis[store],
                  let oldestMs = snapshot.storeOldestMillis[store],
                  lastMs != oldestMs else { continue }

            let spanDays = Double(lastMs - oldestMs) / (1000 * 86400)
            let avgDays = Int(spanDays / Double(allTimeCount - 1))
            guard avgDays > 0, avgDays <= 14 else { continue }

            let daysSinceLast = Int((nowMs - lastMs) / (1000 * 86400))
            guard daysSinceLast > avgDays * 2 else { continue }

            if best == nil || daysSinceLast > best!.daysSince {
                best = (store, daysSinceLast, avgDays)
            }
        }
        guard let b = best else { return nil }

        return StoreIntelligence(
            kind: .absentRegular,
            storeName: b.store,
            title: "Tu n'es pas allé(e) chez \(b.store) depuis \(b.daysSince) j",
            subtitle: "Fréquence habituelle : tous les \(b.avgDays) jours",
            icon: "clock.badge.questionmark"
        )
    }

    // MARK: - Règle 4 : Nouveau commerçant (1 ticket < 7 jours)

    private static func newMerchant(
        snapshot: HomeSnapshot,
        now: Date
    ) -> StoreIntelligence? {
        let nowMs = Int64(now.timeIntervalSince1970 * 1000)
        let sevenDaysMs: Int64 = 7 * 24 * 3600 * 1000

        var best: (store: String, amount: Double, daysAgo: Int)?
        for (store, allTimeCount) in snapshot.storeAllTimeCounts {
            guard allTimeCount == 1 else { continue }
            guard let lastMs = snapshot.storeLastVisitMillis[store] else { continue }
            let age = nowMs - lastMs
            guard age < sevenDaysMs else { continue }
            let amount = snapshot.storeTotals[store] ?? 0
            if best == nil || amount > best!.amount {
                let daysAgo = Int(age / (1000 * 86400))
                best = (store, amount, daysAgo)
            }
        }
        guard let b = best else { return nil }

        let daysLabel = b.daysAgo == 0 ? "aujourd'hui" : "il y a \(b.daysAgo) j"
        return StoreIntelligence(
            kind: .newMerchant,
            storeName: b.store,
            title: "Nouveau : \(b.store)",
            subtitle: "\(euros(b.amount)) · première visite \(daysLabel)",
            icon: "sparkles"
        )
    }

    // MARK: - Helpers

    private static func euros(_ value: Double) -> String {
        String(format: "%.0f €", value)
    }
}
