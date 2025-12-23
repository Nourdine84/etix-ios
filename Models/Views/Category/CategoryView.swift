import SwiftUI
import CoreData

struct CategoryView: View {

    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = CategoryCRUDViewModel.shared
    @State private var showAddSheet = false

    var body: some View {
        NavigationView {
            List {
                activeCategoriesSection
                archivedCategoriesSection
                emptyStateSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Catégories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddCategorySheet(vm: vm)
            }
        }
    }

    // MARK: - Sections

    private var activeCategoriesSection: some View {
        Group {
            if !vm.categories.isEmpty {
                Section(header: Text("Mes catégories")) {
                    ForEach(vm.categories, id: \.objectID) { category in
                        CategoryRowView(category: category)
                            .swipeActions {
                                Button(role: .destructive) {
                                    vm.archive(category)
                                } label: {
                                    Label("Archiver", systemImage: "archivebox")
                                }
                            }
                    }
                }
            }
        }
    }

    private var archivedCategoriesSection: some View {
        Group {
            if !vm.archivedCategories.isEmpty {
                Section(header: Text("Catégories archivées")) {
                    ForEach(vm.archivedCategories, id: \.objectID) { category in
                        CategoryRowView(category: category, archived: true)
                            .swipeActions {
                                Button {
                                    vm.restore(category)
                                } label: {
                                    Label("Restaurer", systemImage: "arrow.uturn.left")
                                }
                                .tint(.blue)
                            }
                    }
                }
            }
        }
    }

    private var emptyStateSection: some View {
        Group {
            if vm.categories.isEmpty && vm.archivedCategories.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)

                    Text("Aucune catégorie")
                        .font(.headline)

                    Text("Ajoute ta première catégorie pour organiser tes tickets.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .listRowBackground(Color.clear)
            }
        }
    }
}
