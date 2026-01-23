import SwiftUI
import CoreData

struct CategoryView: View {

    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = CategoryViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    if !vm.categories.isEmpty {
                        CategoryDonutView(
                            categories: vm.categories,
                            total: vm.grandTotal
                        )
                    }

                    VStack(spacing: 12) {
                        ForEach(vm.categories) { cat in
                            CategoryRowView(
                                category: cat,
                                percent: percent(for: cat)
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Catégories")
            .onAppear {
                vm.load(context: context)
            }
        }
    }

    private func percent(for category: CategoryTotal) -> Double {
        guard vm.grandTotal > 0 else { return 0 }
        return (category.total / vm.grandTotal) * 100
    }
}
