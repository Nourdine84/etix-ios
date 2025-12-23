import Foundation
import CoreData
import SwiftUI

final class CategoryCRUDViewModel: ObservableObject {

    // MARK: - Singleton (stable pour SwiftUI)
    static let shared = CategoryCRUDViewModel()

    // MARK: - Published
    @Published var categories: [Category] = []
    @Published var archivedCategories: [Category] = []

    // MARK: - Core Data
    private let context: NSManagedObjectContext

    // MARK: - Init
    private init() {
        self.context = PersistenceController.shared.container.viewContext
        fetchAll()
        seedIfNeeded()
    }

    // MARK: - Fetch
    func fetchAll() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: true)
        ]

        do {
            let result = try context.fetch(request)
            categories = result.filter { !$0.isArchived }
            archivedCategories = result.filter { $0.isArchived }
        } catch {
            print("❌ Category fetch error:", error.localizedDescription)
            categories = []
            archivedCategories = []
        }
    }

    // MARK: - Create
    func addCategory(
        name: String,
        icon: String,
        colorHex: String? = nil
    ) {
        let category = Category(context: context)
        category.id = UUID()
        category.name = name
        category.icon = icon
        category.colorHex = colorHex
        category.createdAt = Date()
        category.updatedAt = Date()
        category.isArchived = false

        save()
    }

    // MARK: - Archive / Restore
    func archive(_ category: Category) {
        category.isArchived = true
        category.updatedAt = Date()
        save()
    }

    func restore(_ category: Category) {
        category.isArchived = false
        category.updatedAt = Date()
        save()
    }

    // MARK: - Delete
    func delete(_ category: Category) {
        context.delete(category)
        save()
    }

    // MARK: - Save
    private func save() {
        do {
            try context.save()
            fetchAll()
        } catch {
            print("❌ Category save error:", error.localizedDescription)
        }
    }

    // MARK: - Seed initial categories
    private func seedIfNeeded() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.fetchLimit = 1

        let count = (try? context.count(for: request)) ?? 0
        guard count == 0 else { return }

        let defaults: [(String, String, String)] = [
            ("Supermarché", "cart.fill", "#3B82F6"),
            ("Restaurant", "fork.knife", "#EF4444"),
            ("Transport", "car.fill", "#F59E0B"),
            ("Santé", "cross.case.fill", "#10B981"),
            ("Loisirs", "gamecontroller.fill", "#8B5CF6")
        ]

        defaults.forEach {
            addCategory(name: $0.0, icon: $0.1, colorHex: $0.2)
        }

        print("✅ Default categories seeded")
    }
}
