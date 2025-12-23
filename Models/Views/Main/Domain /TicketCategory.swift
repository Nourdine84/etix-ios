import Foundation

enum TicketCategory: String, CaseIterable, Identifiable {
    case groceries = "Courses"
    case restaurant = "Restaurant"
    case transport = "Transport"
    case health = "Santé"
    case leisure = "Loisirs"
    case bills = "Factures"
    case other = "Autre"

    var id: String { rawValue }
}
