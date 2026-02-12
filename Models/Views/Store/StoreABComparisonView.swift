import SwiftUI
import CoreData

struct StoreABComparisonView: View {

    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = StoreABComparisonViewModel()

    let stores: [String]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    selector

                    if let a = vm.itemA, let b = vm.itemB {
                        comparisonHeader(a: a, b: b)
                        comparisonCards(a: a, b: b)
                        insights
                    }
                }
                .padding()
            }
            .navigationTitle("Comparaison A/B")
            .onChange(of: vm.storeA) { _ in load() }
            .onChange(of: vm.storeB) { _ in load() }
        }
    }

    // MARK: - Selector
    private var selector: some View {
        VStack(spacing: 12) {
            Picker("Magasin A", selection: $vm.storeA) {
                Text("—").tag(String?.none)
                ForEach(stores, id: \.self) {
                    Text($0).tag(Optional($0))
                }
            }

            Picker("Magasin B", selection: $vm.storeB) {
                Text("—").tag(String?.none)
                ForEach(stores, id: \.self) {
                    Text($0).tag(Optional($0))
                }
            }
        }
    }

    // MARK: - Header
    private func comparisonHeader(
        a: StoreABComparisonItem,
        b: StoreABComparisonItem
    ) -> some View {

        VStack(spacing: 6) {
            Text("Comparaison directe")
                .font(.headline)

            Text("Δ \(format(vm.deltaTotal)) • \(String(format: "%.1f", vm.deltaPercent)) %")
                .fontWeight(.semibold)
                .foregroundColor(vm.deltaTotal >= 0 ? .green : .red)
        }
    }

    // MARK: - Cards
    private func comparisonCards(
        a: StoreABComparisonItem,
        b: StoreABComparisonItem
    ) -> some View {

        HStack(spacing: 16) {

            storeCard(a, color: .blue)
            storeCard(b, color: .orange)
        }
    }

    private func storeCard(
        _ item: StoreABComparisonItem,
        color: Color
    ) -> some View {

        VStack(spacing: 6) {
            Text(item.storeName)
                .font(.headline)

            Text(format(item.total))
                .font(.title2.bold())
                .foregroundColor(color)

            Text("\(item.ticketCount) ticket(s)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    // MARK: - Insights
    private var insights: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Insight")
                .font(.headline)

            if vm.deltaTotal > 0 {
                Text("📈 \(vm.storeA ?? "") dépense plus que \(vm.storeB ?? "")")
            } else {
                Text("📉 \(vm.storeA ?? "") dépense moins que \(vm.storeB ?? "")")
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    private func load() {
        vm.load(context: context)
    }

    private func format(_ value: Double) -> String {
        String(format: "%.2f €", value)
    }
}
