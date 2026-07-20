import SwiftUI
import CoreData

/// Home V3 Cockpit — maquette Accueil V2 + Intelligence Layer + Design System.
///
/// Architecture performance : un **unique** `HomeSnapshot` est construit par
/// render (un seul passage O(N) sur les tickets), puis threadé aux moteurs et
/// aux sous-vues. Plus aucune couche KPI legacy en parallèle : tous les
/// agrégats dérivent du snapshot.
///
/// Cartes contextuelles : Budget ⊻ Store, résolues de façon déterministe
/// (voir `resolveContextCard`).
struct HomeView: View {

    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    @State private var range: TimeRange = AppSettings.load().defaultRange
    @State private var budgets: [String: Double] = BudgetStore.load()

    // MARK: - Carte contextuelle

    private enum ContextCard {
        case budget(BudgetSummary)
        case store(StoreIntelligence)
        case none
    }

    /// Règle déterministe (validée) — une seule carte contextuelle :
    /// 1. Budget si une **action est nécessaire** (état critical/exceeded ≥ 80 %)
    /// 2. sinon Store Intelligence (hors doublon `dominantStore` déjà en insight)
    /// 3. sinon Budget informatif (comfortable/caution)
    /// 4. sinon aucune
    ///
    /// A3 — « une info une seule fois » : quand l'insight `budgetExceeded` est
    /// affiché, la carte Budget est masquée **uniquement si elle ne ferait que
    /// le répéter** (un seul budget suivi = même catégorie que l'insight). Dès
    /// qu'elle apporte plus (≥ 2 catégories : vue globale, budget restant,
    /// progression), elle reste.
    private func resolveContextCard(
        budget: BudgetSummary?,
        store: StoreIntelligence?,
        insights: [HomeInsight]
    ) -> ContextCard {
        if let b = budget, b.state == .critical || b.state == .exceeded {
            let repeatsInsight = insights.first?.id == .budgetExceeded
                && b.lines.count <= 1
            if !repeatsInsight { return .budget(b) }
            // Carte masquée (pur doublon) — on laisse la place au Store le cas échéant.
            if let s = store { return .store(s) }
            return .none
        }
        if let s = store {
            let duplicatesInsight = s.kind == .dominantStore
                && insights.contains { $0.id == .dominantStore }
            if !duplicatesInsight { return .store(s) }
        }
        if let b = budget { return .budget(b) }
        return .none
    }

    // MARK: - Body

    var body: some View {
        // Source unique — un seul passage O(N).
        let snap = HomeSnapshot(tickets: Array(tickets), range: range)
        let rawStore = StoreIntelligenceEngine.evaluate(snapshot: snap, range: range)
        let insights = HomeInsightEngine.evaluate(
            snapshot: snap,
            budgets: budgets,
            range: range,
            storeIntelligence: rawStore
        )
        let budget = range == .month
            ? BudgetSummaryEngine.compute(snapshot: snap, budgets: budgets)
            : nil
        let contextCard = resolveContextCard(budget: budget, store: rawStore, insights: insights)

        return NavigationStack {
            ZStack {
                Theme.Background.primary
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Theme.Spacing.section) {
                        header(allTime: snap.allTimeTicketCount)
                        heroCard(snap: snap)
                        periodSelector

                        if !insights.isEmpty {
                            insightCards(insights)
                        }

                        contextCardView(contextCard)

                        if snap.allTimeTicketCount > 0 {
                            trendCard(snap: snap)
                        }

                        actions
                    }
                    .padding(.horizontal, Theme.Spacing.xxl)
                    .padding(.top, Theme.Spacing.xl)
                    .padding(.bottom, Theme.Spacing.section)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                budgets = BudgetStore.load()
            }
        }
    }

    // MARK: - Header

    /// Badge « e » (identité, continuité Splash/Onboarding) + titre + greeting
    /// générique (aucun prénom, pas de profil) + nombre de tickets enregistrés.
    private func header(allTime: Int) -> some View {
        VStack(spacing: Theme.Spacing.m) {
            EtixBadge(size: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text("Accueil")
                    .font(Theme.Typography.screenTitle)
                    .foregroundColor(.primary)
                Text(greeting)
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(.secondary)
                Text(countLabel(allTime))
                    .font(Theme.Typography.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Hero

    /// Hero épuré : montant principal directement sur le fond, avec un glow
    /// statique discret derrière (aucune animation, aucune surface, aucune
    /// mascotte). Hiérarchie typographique = overline → montant → delta.
    private func heroCard(snap: HomeSnapshot) -> some View {
        let total = snap.periodTotal
        let previous = snap.previousPeriodTotal
        let delta: Double? = previous > 0 ? (total - previous) / previous * 100 : nil

        return ZStack {
            RadialGradient(
                colors: [Theme.primaryBlue.opacity(0.18), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 180
            )
            .frame(height: 190)
            .blur(radius: 30)
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: Theme.Spacing.s) {
                SectionLabel(text: heroLabel)

                AnimatedAmountText(value: total)
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                if let delta {
                    deltaChip(delta)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// Sémantique financière verrouillée : hausse des dépenses = rouge,
    /// baisse = vert.
    private func deltaChip(_ delta: Double) -> some View {
        let isUp = delta >= 0
        let color: Color = isUp ? .red : .green
        return HStack(spacing: 4) {
            Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
            Text(String(format: "%+.1f %%", delta))
            Text(deltaLabel)
                .foregroundColor(.secondary)
        }
        .font(.caption.weight(.semibold))
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }

    // MARK: - Period Selector

    private var periodSelector: some View {
        Picker("Période", selection: $range) {
            ForEach(TimeRange.allCases) { r in
                Text(r.title).tag(r)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Insights (≤ 2)

    private func insightCards(_ insights: [HomeInsight]) -> some View {
        VStack(spacing: Theme.Spacing.m) {
            ForEach(Array(insights.enumerated()), id: \.element.id) { index, insight in
                InsightCardView(insight: insight, isPrimary: index == 0)
            }
        }
    }

    // MARK: - Carte contextuelle

    @ViewBuilder
    private func contextCardView(_ card: ContextCard) -> some View {
        switch card {
        case .budget(let summary):
            BudgetSummaryCardView(summary: summary)
        case .store(let intelligence):
            StoreIntelligenceCardView(intelligence: intelligence)
        case .none:
            EmptyView()
        }
    }

    // MARK: - Aperçu utile : tendance 6 mois + panier moyen

    private func trendCard(snap: HomeSnapshot) -> some View {
        let points = TrendEngine.monthlyTrend(tickets: Array(tickets))
        let average = snap.periodTicketCount > 0
            ? snap.periodTotal / Double(snap.periodTicketCount)
            : 0

        return NavigationLink {
            MonthlyReportView()
        } label: {
            VStack(alignment: .leading, spacing: Theme.Spacing.l) {
                HStack {
                    SectionLabel(text: "Tendance 6 mois")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                trendBars(points)

                Divider()

                StatBlock(label: "Panier moyen", value: euros2(average))
            }
            .card()
        }
        .buttonStyle(.plain)
    }

    private func trendBars(_ points: [MonthlyTrendPoint]) -> some View {
        let maxValue = max(points.map(\.total).max() ?? 1, 1)
        return HStack(alignment: .bottom, spacing: Theme.Spacing.s) {
            ForEach(Array(points.enumerated()), id: \.element.id) { index, point in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(
                            index == points.count - 1
                                ? Theme.primaryBlue
                                : Theme.primaryBlue.opacity(0.30)
                        )
                        .frame(height: max(6, CGFloat(point.total / maxValue) * 70))
                    Text(point.month)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 92, alignment: .bottom)
    }

    // MARK: - Actions

    /// Scanner = action principale (bleu). Ajout manuel = secondaire.
    private var actions: some View {
        VStack(spacing: Theme.Spacing.m) {
            NavigationLink {
                AddTicketView(autoStartScanner: true)
            } label: {
                actionLabel(icon: "camera.viewfinder", title: "Scanner un ticket")
                    .foregroundColor(.white)
                    .background(Theme.primaryBlue)
                    .cornerRadius(Theme.Radius.button)
                    .shadow(color: Theme.primaryBlue.opacity(0.30), radius: 8, y: 4)
            }
            .buttonStyle(.plain)

            NavigationLink {
                AddTicketView()
            } label: {
                actionLabel(icon: "plus", title: "Ajout manuel")
                    .foregroundColor(.primary)
                    .background(Theme.Background.surface)
                    .cornerRadius(Theme.Radius.button)
            }
            .buttonStyle(.plain)
        }
    }

    private func actionLabel(icon: String, title: String) -> some View {
        HStack(spacing: Theme.Spacing.s) {
            Image(systemName: icon)
                .font(.headline)
            Text(title)
                .font(Theme.Typography.headline)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
    }

    // MARK: - Labels dérivés

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return (5..<18).contains(hour) ? "Bonjour" : "Bonsoir"
    }

    private func countLabel(_ count: Int) -> String {
        count == 0
            ? "Aucun ticket enregistré"
            : "\(count) ticket\(count > 1 ? "s" : "") enregistré\(count > 1 ? "s" : "")"
    }

    private var heroLabel: String {
        switch range {
        case .today: return "Dépenses du jour"
        case .month: return "Dépenses du mois"
        case .year:  return "Dépenses de l'année"
        }
    }

    private var deltaLabel: String {
        switch range {
        case .today: return "vs hier"
        case .month: return "vs mois dernier"
        case .year:  return "vs an dernier"
        }
    }

    private func euros2(_ value: Double) -> String {
        String(format: "%.2f €", value)
    }
}

#Preview("Light") {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}

#Preview("Dark") {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        .preferredColorScheme(.dark)
}
