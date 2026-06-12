import SwiftUI

final class OnboardingViewModel: ObservableObject {

    /// Arc narratif validé : Promesse → Mécanique → Payoff.
    @Published var pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Bienvenue sur eTix",
            subtitle: "Retrouvez tous vos tickets au même endroit.",
            hero: .badge,
            features: []
        ),
        OnboardingPage(
            title: "Ajoute, classe, retrouve",
            subtitle: "Scannez vos tickets, organisez vos achats et retrouvez chaque dépense facilement.",
            hero: nil,
            features: [
                OnboardingPage.Feature(
                    icon: "camera.fill",
                    keyword: "Scannez",
                    text: "depuis une photo ou en saisie manuelle"
                ),
                OnboardingPage.Feature(
                    icon: "folder.fill",
                    keyword: "Classez",
                    text: "par catégorie, automatiquement"
                ),
                OnboardingPage.Feature(
                    icon: "magnifyingglass",
                    keyword: "Retrouvez",
                    text: "vos achats par magasin ou catégorie"
                )
            ]
        ),
        OnboardingPage(
            title: "Gardez le contrôle de vos dépenses",
            subtitle: "Comprenez où va votre argent, suivez vos budgets et retrouvez chaque achat en quelques secondes.",
            hero: .symbol("chart.line.uptrend.xyaxis"),
            features: []
        )
    ]

    @Published var index: Int = 0
    @AppStorage("app.hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    var isLastPage: Bool { index == pages.count - 1 }

    func next() {
        if isLastPage {
            hasSeenOnboarding = true
        } else {
            withAnimation(.easeInOut) { index += 1 }
        }
    }

    func skip() {
        hasSeenOnboarding = true
    }
}
