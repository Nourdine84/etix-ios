import Foundation

enum TimeRange: String, CaseIterable, Identifiable {

    case today
    case month
    case year

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: return "Aujourd’hui"
        case .month: return "Ce mois"
        case .year: return "Cette année"
        }
    }
}
