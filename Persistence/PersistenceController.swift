import CoreData

final class PersistenceController: ObservableObject {

    static let shared = PersistenceController()

    let container: NSPersistentContainer

    private init(inMemory: Bool = false) {

        // --- Model déclaré en code ---
        let model = NSManagedObjectModel()

        let ticketEntity = NSEntityDescription()
        ticketEntity.name = "Ticket"
        ticketEntity.managedObjectClassName = "Ticket"

        // ATTRIBUTS
        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .integer64AttributeType
        id.isOptional = false

        let storeName = NSAttributeDescription()
        storeName.name = "storeName"
        storeName.attributeType = .stringAttributeType
        storeName.isOptional = false

        let amount = NSAttributeDescription()
        amount.name = "amount"
        amount.attributeType = .doubleAttributeType
        amount.isOptional = false

        let dateMillis = NSAttributeDescription()
        dateMillis.name = "dateMillis"
        dateMillis.attributeType = .integer64AttributeType
        dateMillis.isOptional = false

        let category = NSAttributeDescription()
        category.name = "category"
        category.attributeType = .stringAttributeType
        category.isOptional = false

        let desc = NSAttributeDescription()
        desc.name = "ticketDescription"
        desc.attributeType = .stringAttributeType
        desc.isOptional = true

        ticketEntity.properties = [id, storeName, amount, dateMillis, category, desc]
        model.entities = [ticketEntity]

        // --- Container Core Data ---
        container = NSPersistentContainer(name: "eTixModel", managedObjectModel: model)

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("❌ Core Data loading failed: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }

    // MARK: Save
    func save() {
        let ctx = container.viewContext
        if ctx.hasChanges {
            do { try ctx.save() }
            catch { print("❌ Save error:", error.localizedDescription) }
        }
    }

    // MARK: Delete all tickets
    func wipeDatabase() {
        let ctx = container.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Ticket")
        let delete = NSBatchDeleteRequest(fetchRequest: fetch)

        do {
            try container.persistentStoreCoordinator.execute(delete, with: ctx)
            try ctx.save()
            print("🗑️ Base de données nettoyée")
        } catch {
            print("❌ wipeDatabase error:", error.localizedDescription)
        }
    }
}
