import Foundation

enum KPIType: Hashable {
    case today
    case month
    case all

    var title: String {
        switch self {
        case .today: return "Aujourd’hui"
        case .month: return "Ce mois"
        case .all: return "Tous les tickets"
        }
    }
}
