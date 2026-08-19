import SwiftUI
import CoreData

/// History V2 — mission : **« où est mon ticket ? »**.
///
/// Recherche-first (magasin · catégorie · description/OCR), regroupement par
/// jour, rendu via une **dérivation pure unique** (`HistoryDigestEngine`)
/// construite une fois par render — aucun état dérivé stocké, aucun cache.
///
/// History n'est pas une seconde Home : pas de moyenne, pas de magasin
/// dominant, pas de narration financière. Le seul chiffre agrégé est un
/// **compteur de résultat** contextuel.
struct TicketHistoryView: View {

    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    @State private var searchText  = ""
    @State private var showFilter  = false
    @State private var filterStart: Date? = nil
    @State private var filterEnd:   Date? = nil
    @State private var minAmount:   Double? = nil
    @State private var maxAmount:   Double? = nil
    @State private var sort: HistorySort = .recentFirst

    // Actions de ligne (confirmation obligatoire avant suppression).
    @State private var pendingDelete: Ticket? = nil
    @State private var editing: Ticket? = nil

    // MARK: - Requête (source unique de la dérivation)

    private var query: HistoryQuery {
        HistoryQuery(
            text: searchText,
            startDate: filterStart,
            endDate: filterEnd,
            minAmount: minAmount,
            maxAmount: maxAmount,
            sort: sort
        )
    }

    /// Un **filtre** est actif (le tri seul ne compte pas — cf. `isNarrowed`).
    private var isFilterActive: Bool {
        filterStart != nil || filterEnd != nil || minAmount != nil || maxAmount != nil
    }

    // MARK: - Body

    var body: some View {
        // Dérivation unique — une fois par render (comme HomeSnapshot).
        let digest = HistoryDigestEngine.build(tickets: Array(tickets), query: query)

        return NavigationStack {
            ZStack {
                Theme.Background.primary.ignoresSafeArea()

                if digest.sections.isEmpty {
                    emptyState(isNarrowed: digest.isNarrowed)
                } else {
                    content(digest)
                }
            }
            .navigationTitle("Historique")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilter = true
                    } label: {
                        Image(systemName: isFilterActive
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                            .foregroundColor(isFilterActive ? Theme.primaryBlue : .primary)
                    }
                    .accessibilityLabel("Filtres")
                }
            }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Rechercher un magasin, une catégorie…"
            )
            .sheet(isPresented: $showFilter) {
                TicketFilterSheet(
                    startDate: $filterStart,
                    endDate:   $filterEnd,
                    minAmount: $minAmount,
                    maxAmount: $maxAmount,
                    sort:      $sort,
                    onReset:   resetFilters
                )
            }
            .sheet(item: $editing) { ticket in
                TicketEditView(ticket: ticket)
            }
            .overlay {
                if let ticket = pendingDelete {
                    ConfirmDeletePopup {
                        performDelete(ticket)
                        pendingDelete = nil
                    } onCancel: {
                        pendingDelete = nil
                    }
                    .zIndex(10)
                }
            }
        }
    }

    // MARK: - Contenu

    private func content(_ digest: HistoryDigest<Ticket>) -> some View {
        List {
            Section {
                resultMeter(digest)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: Theme.Spacing.s, leading: Theme.Spacing.xxl,
                                              bottom: 0, trailing: Theme.Spacing.xxl))
            }

            ForEach(digest.sections) { section in
                Section {
                    ForEach(section.rows) { row in
                        NavigationLink {
                            TicketDetailView(ticket: row.item)
                        } label: {
                            TicketRow(ticket: row.item, matchedSnippet: row.snippet)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: Theme.Spacing.xs, leading: Theme.Spacing.xxl,
                                                  bottom: Theme.Spacing.xs, trailing: Theme.Spacing.xxl))
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                pendingDelete = row.item
                            } label: {
                                Label("Supprimer", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button {
                                editing = row.item
                            } label: {
                                Label("Modifier", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                pendingDelete = row.item
                            } label: {
                                Label("Supprimer", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    daySectionHeader(section, showTotal: !digest.isNarrowed)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
    }

    /// Compteur de résultat contextuel — **jamais** un mini-dashboard.
    /// Sans recherche/filtre : « N tickets ». Sinon : « n résultats · total ».
    @ViewBuilder
    private func resultMeter(_ digest: HistoryDigest<Ticket>) -> some View {
        if digest.isNarrowed {
            Text("\(digest.resultCount) résultat\(digest.resultCount > 1 ? "s" : "") · \(amountString(digest.resultTotal))")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
                .accessibilityLabel("\(digest.resultCount) résultats, total \(amountString(digest.resultTotal))")
        } else {
            Text("\(digest.resultCount) ticket\(digest.resultCount > 1 ? "s" : "")")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    /// En-tête de jour — **helper privé** (pas encore un composant DS partagé).
    /// Utilise un style dynamique (`.caption`) pour honorer Dynamic Type.
    private func daySectionHeader(_ section: HistorySection<Ticket>, showTotal: Bool) -> some View {
        HStack {
            Text(section.label.uppercased())
                .font(.caption.weight(.medium))
                .tracking(1)
                .foregroundColor(.secondary)

            Spacer()

            if showTotal {
                Text(amountString(section.dayTotal))
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    // MARK: - États vides

    @ViewBuilder
    private func emptyState(isNarrowed: Bool) -> some View {
        VStack(spacing: Theme.Spacing.l) {
            Image(systemName: isNarrowed ? "magnifyingglass" : "tray")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text(isNarrowed ? "Aucun résultat" : "Aucun ticket")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if isNarrowed {
                Button("Effacer") {
                    searchText = ""
                    resetFilters()
                }
                .font(.caption.weight(.medium))
                .foregroundColor(Theme.primaryBlue)
            }
        }
        .padding(Theme.Spacing.xxl)
    }

    // MARK: - Actions

    /// Réinitialise **les filtres** (pas la recherche ni le tri temporel par
    /// défaut). Utilisé par la sheet et l'état vide.
    private func resetFilters() {
        filterStart = nil
        filterEnd   = nil
        minAmount   = nil
        maxAmount   = nil
        sort        = .recentFirst
    }

    /// Suppression confirmée uniquement (jamais en un seul geste).
    private func performDelete(_ ticket: Ticket) {
        context.delete(ticket)
        do {
            try context.save()
            Haptic.medium()
        } catch {
            print("❌ Delete failed:", error)
        }
    }

    // MARK: - Format

    private func amountString(_ value: Double) -> String {
        String(format: "%.2f €", value)
    }
}
