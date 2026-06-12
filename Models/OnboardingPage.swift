import SwiftUI

struct OnboardingPage: Identifiable, Hashable {

    /// Visuel principal de la page. `nil` quand les feature rows portent
    /// seules le contenu (page Mécanique).
    enum Hero: Hashable {
        case badge              // EtixBadge héros (page Promesse)
        case symbol(String)     // SF Symbol dans un cercle glow (page Payoff)
    }

    struct Feature: Hashable {
        let icon: String        // SF Symbol
        let keyword: String     // verbe en gras
        let text: String        // bénéfice court
    }

    let id = UUID()
    let title: String
    let subtitle: String
    let hero: Hero?
    let features: [Feature]
}
