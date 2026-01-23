import SwiftUI
import CoreData

struct CategoryView: View {

    // MARK: - CoreData
    @Environment(\.managedObjectContext) private var context

    // MARK: - ViewModel
    @StateObject private var vm = CategoryViewModel()

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // 🍩 Donut global
                    if !vm.categories.isEmpty {
                        CategoryDonutView(
                            categories: vm.categories,
                            total: vm.grandTotal
                        )
                    }

                    // 📂 Liste catégories (DRILL)
                    VStack(spacing: 12) {
                        ForEach(vm.categories) { cat in
                            NavigationLink {
                                CategoryDetailView(categoryName: cat.name)
                            } label: {
                                CategoryRowView(
                                    category: cat,
                                    percent: percent(for: cat)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Catégories")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                vm.load(context: context)
            }
        }
    }

    // MARK: - Helpers
    private func percent(for category: CategoryTotal) -> Double {
        guard vm.grandTotal > 0 else { return 0 }
        return (category.total / vm.grandTotal) * 100
    }
}
