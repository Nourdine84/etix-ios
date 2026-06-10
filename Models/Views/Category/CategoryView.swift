import SwiftUI
import CoreData

struct CategoryView: View {

    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = CategoryViewModel()

    @State private var range: TimeRange = AppSettings.load().defaultRange
    @State private var budgets: [String: Double] = BudgetStore.load()
    @State private var showBudgetSettings = false

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
                                        percent: percent(for: cat),
                                        budget: range == .month
                                            ? budgets[cat.name.lowercased()]
                                            : nil,
                                        range: range
                                    )
                                }
                                if budgets.isEmpty {
                                    teaserRow
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showBudgetSettings = true
                    } label: {
                        Image(systemName: "slider.vertical.3")
                    }
                }
            }
            .onAppear {
                vm.load(context: context, range: range)
                budgets = BudgetStore.load()
            }
            .onChange(of: range) { _, _ in
                vm.load(context: context, range: range)
            }
            .sheet(isPresented: $showBudgetSettings, onDismiss: {
                budgets = BudgetStore.load()
            }) {
                BudgetSettingsView()
            }
        }
    }

    // MARK: - Teaser Row

    private var teaserRow: some View {
        Button {
            showBudgetSettings = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle")
                    .foregroundColor(Theme.primaryBlue)
                Text("Définir des budgets mensuels")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
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
