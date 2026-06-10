import SwiftUI
import CoreData

struct CategoryView: View {

    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = CategoryViewModel()

    @State private var range: TimeRange = AppSettings.load().defaultRange

    var body: some View {
        NavigationStack {
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

                if vm.categories.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            CategoryDonutView(
                                categories: vm.categories,
                                total: vm.grandTotal
                            )
                            VStack(spacing: 12) {
                                ForEach(vm.categories) { cat in
                                    CategoryRowView(
                                        category: cat,
                                        percent: percent(for: cat)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Catégories")
            .onAppear {
                vm.load(context: context, range: range)
            }
            .onChange(of: range) { _, _ in
                vm.load(context: context, range: range)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "tag")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("Aucun ticket sur cette période")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    // MARK: - Helpers

    private func percent(for category: CategoryTotal) -> Double {
        guard vm.grandTotal > 0 else { return 0 }
        return (category.total / vm.grandTotal) * 100
    }
}
