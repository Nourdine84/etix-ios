import SwiftUI
import CoreData

struct CategoryDetailView: View {

    let categoryName: String

    @Environment(\.managedObjectContext) private var context
    @FetchRequest private var tickets: FetchedResults<Ticket>

    @State private var range: TimeRange

    init(categoryName: String, initialRange: TimeRange) {
        self.categoryName = categoryName
        _range = State(initialValue: initialRange)
        let request = NSFetchRequest<Ticket>(entityName: "Ticket")
        request.predicate = NSPredicate(format: "category == %@", categoryName)
        request.sortDescriptors = [NSSortDescriptor(key: "dateMillis", ascending: false)]
        _tickets = FetchRequest(fetchRequest: request)
    }

    // MARK: - Filtered

    private var categoryTickets: [Ticket] {
        let r = DateRangeHelper.currentRange(for: range)
        let startMs = DateRangeHelper.millis(r.start)
        let endMs = DateRangeHelper.millis(r.end)
        return tickets.filter { $0.dateMillis >= startMs && $0.dateMillis < endMs }
    }

    private var totalAmount: Double {
        categoryTickets.reduce(0) { $0 + $1.amount }
    }

    private var groupedByDay: [(date: Date, items: [Ticket])] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: categoryTickets) { ticket in
            cal.startOfDay(for: Date(timeIntervalSince1970: TimeInterval(ticket.dateMillis) / 1000))
        }
        return grouped.map { ($0.key, $0.value) }.sorted { $0.0 > $1.0 }
    }

    private var chartData: [(date: Date, total: Double)] {
        groupedByDay
            .map { ($0.date, $0.items.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.date < $1.date }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            Picker("Période", selection: $range) {
                ForEach(TimeRange.allCases) { r in
                    Text(r.title).tag(r)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(.systemGroupedBackground))

            ScrollView {
                VStack(spacing: 24) {

                    // HEADER
                    VStack(alignment: .leading, spacing: 6) {
                        Text(categoryName)
                            .font(.title2.bold())
                        Text(String(format: "%.2f €", totalAmount))
                            .font(.title.bold())
                            .foregroundColor(Theme.primaryBlue)
                        let count = categoryTickets.count
                        Text("\(count) ticket\(count > 1 ? "s" : "")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // DRILL MAGASIN
                    NavigationLink {
                        StoreListView(categoryName: categoryName)
                    } label: {
                        HStack {
                            Image(systemName: "building.2")
                                .foregroundColor(Theme.primaryBlue)
                            Text("Voir par magasin")
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // GRAPH
                    if !chartData.isEmpty {
                        CategoryBarChartView(data: chartData)
                    }

                    // LISTE
                    if groupedByDay.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: 20) {
                            ForEach(groupedByDay, id: \.date) { section in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(sectionTitle(section.date))
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                    VStack(spacing: 10) {
                                        ForEach(section.items, id: \.objectID) { ticket in
                                            NavigationLink {
                                                TicketDetailView(ticket: ticket)
                                            } label: {
                                                ticketRow(ticket)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CategoryExportButton(
                    categoryName: categoryName,
                    tickets: categoryTickets,
                    total: totalAmount
                )
            }
        }
    }

    // MARK: - Helpers

    private func sectionTitle(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Aujourd'hui" }
        if cal.isDateInYesterday(date) { return "Hier" }
        return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    }

    private func ticketRow(_ t: Ticket) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(t.storeName)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.2f €", t.amount))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.primaryBlue)
            }
            Text(DateUtils.shortString(fromMillis: t.dateMillis))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("Aucun ticket sur cette période")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
