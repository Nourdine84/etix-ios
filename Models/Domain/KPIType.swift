enum KPIType: String, Identifiable, CaseIterable {
    case today
    case month
    case tickets

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: return "Aujourd’hui"
        case .month: return "Ce mois"
        case .tickets: return "Tickets"
        }
    }

    var icon: String {
        switch self {
        case .today: return "sun.max.fill"
        case .month: return "calendar"
        case .tickets: return "doc.text"
        }
    }
}
