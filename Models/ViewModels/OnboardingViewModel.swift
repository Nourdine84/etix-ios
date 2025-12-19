import SwiftUI

final class OnboardingViewModel: ObservableObject {
    @Published var pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Bienvenue sur eTix",
            subtitle: "Centralisez vos tickets facilement, sans papier.",
            systemImage: "ticket.fill",
            accent: Color(Theme.primaryBlue)
        ),
        OnboardingPage(
            title: "Ajoutez en 2 secondes",
            subtitle: "Saisissez magasin, montant, date et catégorie.",
            systemImage: "plus.circle.fill",
            accent: Color(Theme.primaryBlue)
        ),
        OnboardingPage(
            title: "Analysez vos dépenses",
            subtitle: "Totaux par catégorie, filtres de période, et plus à venir.",
            systemImage: "chart.bar.fill",
            accent: Color(Theme.primaryBlue)
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
