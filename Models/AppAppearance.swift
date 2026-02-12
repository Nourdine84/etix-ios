import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable {

    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "Système"
        case .light:  return "Clair"
        case .dark:   return "Sombre"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    // 🔥 Valeur par défaut centralisée ici
    static let `default` = AppAppearance.system
}
