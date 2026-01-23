import Foundation

enum KPIType {
    case today
    case month
    case all

    var title: String {
        switch self {
        case .today: return "Aujourd’hui"
        case .month: return "Ce mois"
        case .all: return "Total"
        }
    }

    var identifier: String {
        switch self {
        case .today: return "today"
        case .month: return "month"
        case .all: return "all"
        }
    }
}
