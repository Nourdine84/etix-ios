import SwiftUI
import CoreData

struct StoreABComparisonView: View {

    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    @State private var storeA: String?
    @State private var storeB: String?

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

    var body: some View {
        NavigationStack {
            ZStack {

                DesignSystem.premiumBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignSystem.verticalSpacing) {

                        selectorSection

                        if let a = storeA, let b = storeB {
                            comparisonSection(a: a, b: b)
                        } else {
                            emptyState
                        }
                    }
                    .padding(.horizontal, DesignSystem.horizontalPadding)
                    .padding(.vertical)
                }
            }
            .navigationTitle("Comparaison A/B")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
        }
    }

    private var selectorSection: some View {
        VStack(spacing: DesignSystem.innerSpacing) {

            Picker("Magasin A", selection: $storeA) {
                Text("Choisir").tag(String?.none)
                ForEach(stores, id: \.self) {
                    Text($0).tag(Optional($0))
                }
            }
            .pickerStyle(.menu)
            .premiumCard()

            Picker("Magasin B", selection: $storeB) {
                Text("Choisir").tag(String?.none)
                ForEach(stores, id: \.self) {
                    Text($0).tag(Optional($0))
                }
            }
            .pickerStyle(.menu)
            .premiumCard()
        }
    }

    private func comparisonSection(a: String, b: String) -> some View {

        VStack(spacing: DesignSystem.innerSpacing) {

            VStack(spacing: 6) {

                Text("Écart")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(String(format: "%.2f €", abs(delta)))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(delta >= 0 ? Theme.primaryBlue : .secondary)
            }
            .premiumCard()

            HStack(spacing: DesignSystem.innerSpacing) {
                storeCard(store: a)
                storeCard(store: b)
            }
        }
    }

    private func storeCard(store: String) -> some View {

        VStack(spacing: 10) {

            Text(store)
                .font(.headline)

            Text(String(format: "%.2f €", total(for: store)))
                .font(.title2.bold())
                .foregroundColor(Theme.primaryBlue)

            Text("\(count(for: store)) ticket(s)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .premiumCard()
    }

    private var emptyState: some View {
        VStack(spacing: 16) {

            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 44))
                .foregroundColor(.gray)

            Text("Sélectionnez deux magasins")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}
