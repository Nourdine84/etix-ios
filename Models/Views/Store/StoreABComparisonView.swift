import SwiftUI
import CoreData

struct StoreABComparisonView: View {

    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    @State private var storeA: String?
    @State private var storeB: String?

    // MARK: - Stores List

    private var stores: [String] {
        Array(Set(tickets.map { $0.storeName })).sorted()
    }

    private func total(for store: String) -> Double {
        tickets
            .filter { $0.storeName == store }
            .reduce(0) { $0 + $1.amount }
    }

    private func count(for store: String) -> Int {
        tickets.filter { $0.storeName == store }.count
    }

    private var delta: Double {
        guard let a = storeA, let b = storeB else { return 0 }
        return total(for: a) - total(for: b)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {

                DesignSystem.pageBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {

                        selectorSection

                        if let a = storeA, let b = storeB {
                            comparisonSection(a: a, b: b)
                        } else {
                            emptyState
                        }
                    }
                    .padding(.horizontal, DesignSystem.horizontalPadding)
                    .padding(.vertical, 30)
                }
            }
            .navigationTitle("Comparaison A/B")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Selector

    private var selectorSection: some View {
        VStack(spacing: 20) {

            VStack(alignment: .leading, spacing: 6) {
                Text("Magasin A")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Picker("", selection: $storeA) {
                    Text("Choisir").tag(String?.none)
                    ForEach(stores, id: \.self) {
                        Text($0).tag(Optional($0))
                    }
                }
                .pickerStyle(.menu)
            }
            .premiumCard()

            VStack(alignment: .leading, spacing: 6) {
                Text("Magasin B")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Picker("", selection: $storeB) {
                    Text("Choisir").tag(String?.none)
                    ForEach(stores, id: \.self) {
                        Text($0).tag(Optional($0))
                    }
                }
                .pickerStyle(.menu)
            }
            .premiumCard()
        }
    }

    // MARK: - Comparison

    private func comparisonSection(a: String, b: String) -> some View {

        VStack(spacing: 24) {

            deltaCard

            HStack(spacing: 20) {
                storeCard(store: a)
                storeCard(store: b)
            }
        }
    }

    // MARK: - Delta Card

    private var deltaCard: some View {

        VStack(spacing: 6) {

            Text("Écart")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(String(format: "%.2f €", abs(delta)))
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(
                    delta >= 0
                    ? Theme.primaryBlue
                    : .secondary
                )
        }
        .premiumCard()
    }

    // MARK: - Store Card

    private func storeCard(store: String) -> some View {

        VStack(spacing: 10) {

            Text(store)
                .font(.headline)

            Text(String(format: "%.2f €", total(for: store)))
                .font(.title2.weight(.semibold))
                .foregroundColor(Theme.primaryBlue)

            Text("\(count(for: store)) ticket(s)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .premiumCard()
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 18) {

            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 44))
                .foregroundColor(.gray)

            Text("Sélectionnez deux magasins")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 80)
    }
}
