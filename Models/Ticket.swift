import Foundation
import CoreData

@objc(Ticket)
class Ticket: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var storeName: String
    @NSManaged var amount: Double
    @NSManaged var dateMillis: Int64
    @NSManaged var category: String
    @NSManaged var ticketDescription: String?
}

// Pour ForEach(tickets) si tu ne mets pas id:\.objectID
extension Ticket: Identifiable {}

extension Ticket {

    /// FetchRequest de base générée (pas obligatoire, mais utile si besoin)
    @nonobjc class func fetchRequest() -> NSFetchRequest<Ticket> {
        NSFetchRequest<Ticket>(entityName: "Ticket")
    }

    /// Création + sauvegarde d’un ticket (ISO Android avec dateMillis en ms)
    static func create(
        storeName: String,
        amount: Double,
        dateMillis: Int64,
        category: String,
        description: String?,
        in context: NSManagedObjectContext
    ) {
        let ticket = Ticket(context: context)
        ticket.id = Int64(Date().timeIntervalSince1970 * 1000) // id pseudo-unique
        ticket.storeName = storeName
        ticket.amount = amount
        ticket.dateMillis = dateMillis
        ticket.category = category
        ticket.ticketDescription = description

        do {
            try context.save()
        } catch {
            print("❌ CoreData save error:", error.localizedDescription)
        }
    }

    /// Tous les tickets triés par date décroissante (dateMillis)
    static func fetchAllRequest() -> NSFetchRequest<Ticket> {
        let req = NSFetchRequest<Ticket>(entityName: "Ticket")
        req.sortDescriptors = [NSSortDescriptor(key: "dateMillis", ascending: false)]
        return req
    }

    /// Tickets entre deux timestamps (ms)
    static func fetchBetween(start: Int64, end: Int64) -> NSFetchRequest<Ticket> {
        let req = NSFetchRequest<Ticket>(entityName: "Ticket")
        req.predicate = NSPredicate(format: "dateMillis >= %lld AND dateMillis <= %lld", start, end)
        req.sortDescriptors = [NSSortDescriptor(key: "dateMillis", ascending: false)]
        return req
    }
}
