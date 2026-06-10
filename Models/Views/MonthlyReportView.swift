import SwiftUI
import CoreData

struct MonthlyReportView: View {

    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    @State private var showShareSheet = false
    @State private var pdfData: Data? = nil

    // MARK: - Periods

    private var currentRange: (start: Date, end: Date) {
        DateRangeHelper.currentRange(for: .month)
    }
    private var previousRange: (start: Date, end: Date) {
        DateRangeHelper.previousRange(for: .month)
    }

    private var monthTickets: [Ticket] {
        let s = DateRangeHelper.millis(currentRange.start)
        let e = DateRangeHelper.millis(currentRange.end)
        return tickets.filter { $0.dateMillis >= s && $0.dateMillis < e }
    }

    private var previousMonthTickets: [Ticket] {
        let s = DateRangeHelper.millis(previousRange.start)
        let e = DateRangeHelper.millis(previousRange.end)
        return tickets.filter { $0.dateMillis >= s && $0.dateMillis < e }
    }

    // MARK: - KPIs

    private var monthTotal: Double   { monthTickets.reduce(0) { $0 + $1.amount } }
    private var ticketCount: Int     { monthTickets.count }
    private var averageAmount: Double {
        ticketCount > 0 ? monthTotal / Double(ticketCount) : 0
    }
    private var previousTotal: Double {
        previousMonthTickets.reduce(0) { $0 + $1.amount }
    }
    private var deltaPercent: Double? {
        guard previousTotal > 0 else { return nil }
        return ((monthTotal - previousTotal) / previousTotal) * 100
    }

    // MARK: - Analytics

    private var topCategory: (name: String, total: Double)? {
        Dictionary(grouping: monthTickets) { $0.category }
            .map { (key: $0.key.isEmpty ? "Autre" : $0.key, value: $0.value.reduce(0) { $0 + $1.amount }) }
            .max { $0.value < $1.value }
            .map { (name: $0.key, total: $0.value) }
    }

    private var topStore: (name: String, total: Double)? {
        Dictionary(grouping: monthTickets) { $0.storeName }
            .map { (key: $0.key, value: $0.value.reduce(0) { $0 + $1.amount }) }
            .max { $0.value < $1.value }
            .map { (name: $0.key, total: $0.value) }
    }

    private var biggestTicket: Ticket? {
        monthTickets.max { $0.amount < $1.amount }
    }

    private var categoryBreakdown: [(name: String, total: Double, percent: Double)] {
        let grouped = Dictionary(grouping: monthTickets) { $0.category }
        let pairs: [(String, Double)] = grouped.map { key, values in
            (key.isEmpty ? "Autre" : key, values.reduce(0) { $0 + $1.amount })
        }
        let grandTotal = pairs.reduce(0) { $0 + $1.1 }
        return pairs
            .map { (name: $0.0, total: $0.1, percent: grandTotal > 0 ? $0.1 / grandTotal * 100 : 0) }
            .sorted { $0.total > $1.total }
    }

    private var exceededBudgets: [(name: String, spent: Double, limit: Double)] {
        let budgets = BudgetStore.load()
        guard !budgets.isEmpty else { return [] }
        let spentByKey = Dictionary(grouping: monthTickets) { $0.category.lowercased() }
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
        let displayNames = Dictionary(
            monthTickets.map { ($0.category.lowercased(), $0.category) },
            uniquingKeysWith: { first, _ in first }
        )
        return budgets.compactMap { key, limit in
            let spent = spentByKey[key] ?? 0
            guard spent > limit else { return nil }
            return (name: displayNames[key] ?? key.capitalized, spent: spent, limit: limit)
        }
        .sorted { $0.spent / $0.limit > $1.spent / $1.limit }
    }

    // MARK: - Labels

    private var monthName: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "fr_FR")
        df.dateFormat = "MMMM yyyy"
        return df.string(from: Date()).capitalized
    }

    private var previousMonthName: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "fr_FR")
        df.dateFormat = "MMMM"
        return df.string(from: previousRange.start)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            if monthTickets.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        resumeSection
                        evolutionSection
                        if !exceededBudgets.isEmpty { budgetsSection }
                        highlightsSection
                        if !categoryBreakdown.isEmpty { breakdownSection }
                        exportButton
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 48)
                }
                .scrollIndicators(.hidden)
            }
        }
        .navigationTitle("Rapport de \(monthName)")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let data = pdfData {
                ReportActivityView(items: [data])
            }
        }
    }

    // MARK: - Sections

    private var resumeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            label("RÉSUMÉ DU MOIS")
            HStack(spacing: 16) {
                kpiBlock(title: "TOTAL",   value: String(format: "%.2f €", monthTotal))
                kpiBlock(title: "TICKETS", value: "\(ticketCount)")
            }
            kpiBlock(title: "PANIER MOYEN", value: String(format: "%.2f €", averageAmount))
        }
        .reportCard()
    }

    private var evolutionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            label("ÉVOLUTION")
            if let delta = deltaPercent {
                HStack(spacing: 10) {
                    Image(systemName: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(delta >= 0 ? .red : .green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(format: "%+.1f%%", delta))
                            .font(.title3.weight(.semibold))
                            .foregroundColor(delta >= 0 ? .red : .green)
                        Text("vs \(previousMonthName) · \(String(format: "%.2f €", previousTotal))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                Text("Aucune donnée le mois précédent")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .reportCard()
    }

    private var budgetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            label("BUDGETS DÉPASSÉS")
            ForEach(exceededBudgets, id: \.name) { b in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(b.name)
                            .font(.subheadline.weight(.medium))
                        Text(String(format: "%.0f € / %.0f €", b.spent, b.limit))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(String(format: "+%.0f%%", (b.spent / b.limit - 1) * 100))
                        .font(.caption.weight(.bold))
                        .foregroundColor(.red)
                }
            }
        }
        .reportCard()
    }

    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            label("HIGHLIGHTS")
            if let cat = topCategory {
                highlightRow(label: "TOP CATÉGORIE",
                             primary: cat.name,
                             secondary: String(format: "%.2f €", cat.total))
            }
            if let store = topStore {
                highlightRow(label: "TOP MAGASIN",
                             primary: store.name,
                             secondary: String(format: "%.2f €", store.total))
            }
            if let t = biggestTicket {
                highlightRow(label: "PLUS GROS ACHAT",
                             primary: String(format: "%.2f €", t.amount),
                             secondary: "\(t.storeName) · \(DateUtils.shortString(fromMillis: t.dateMillis))")
            }
        }
        .reportCard()
    }

    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            label("RÉPARTITION")
            ForEach(categoryBreakdown, id: \.name) { cat in
                HStack(spacing: 8) {
                    Text(cat.name)
                        .font(.caption)
                        .lineLimit(1)
                        .frame(width: 90, alignment: .leading)
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(.systemFill)).frame(height: 4)
                        Capsule()
                            .fill(Theme.primaryBlue.opacity(0.7))
                            .scaleEffect(x: min(cat.percent / 100, 1.0), anchor: .leading)
                            .frame(height: 4)
                    }
                    Text(String(format: "%.0f%%", cat.percent))
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.secondary)
                        .frame(width: 30, alignment: .trailing)
                    Text(String(format: "%.0f €", cat.total))
                        .font(.caption2.weight(.semibold))
                        .frame(width: 52, alignment: .trailing)
                }
            }
        }
        .reportCard()
    }

    private var exportButton: some View {
        Button {
            Haptic.light()
            if let data = try? PDFExportService.exportCurrentMonthTickets(context: context) {
                pdfData = data
                showShareSheet = true
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                Text("Exporter les tickets en PDF")
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(Theme.primaryBlue)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.primaryBlue.opacity(0.1))
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("Aucune activité ce mois")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Helpers

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .tracking(1)
            .foregroundColor(.secondary)
    }

    private func kpiBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .tracking(0.8)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func highlightRow(label: String, primary: String, secondary: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .tracking(0.8)
                    .foregroundColor(.secondary)
                Text(primary)
                    .font(.subheadline.weight(.semibold))
            }
            Spacer()
            Text(secondary)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Card Style

private extension View {
    func reportCard() -> some View {
        self
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(20)
    }
}

// MARK: - PDF Share

private struct ReportActivityView: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
