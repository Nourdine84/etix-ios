import Foundation
import SwiftUI

final class SessionViewModel: ObservableObject {
    enum AppState {
        case splash
        case onboarding
        case ready
    }

    @Published var appState: AppState = .splash

    @AppStorage("app.hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    // Called by SplashView after its animation completes
    func decideNextAfterSplash() {
        appState = hasSeenOnboarding ? .ready : .onboarding
    }

    // Called by OnboardingView when the user finishes or skips
    func finishOnboarding() {
        hasSeenOnboarding = true
        appState = .ready
    }
}
