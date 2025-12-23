import Foundation
import CoreData

@objc(Ticket)
public class Ticket: NSManagedObject {}

extension Ticket {

    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Ticket> {
        NSFetchRequest<Ticket>(entityName: "Ticket")
    }

    @NSManaged public var storeName: String
    @NSManaged public var amount: Double
    @NSManaged public var dateMillis: Int64
    @NSManaged public var category: String
    @NSManaged public var ticketDescription: String?
}

extension Ticket: Identifiable {}
