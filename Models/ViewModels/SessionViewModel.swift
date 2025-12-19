import Foundation
import SwiftUI

final class SessionViewModel: ObservableObject {
    enum AppState {
        case splash
        case onboarding
        case unauthenticated
        case authenticated
    }

    @Published var appState: AppState = .splash

    private let key = "isLoggedIn"
    @AppStorage("app.hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    init() {
        // ⏱️ Splash court puis décision de navigation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { [weak self] in
            self?.decideNextAfterSplash()
        }
    }

    /// 🔁 Décide vers quelle vue aller après le splash
    func decideNextAfterSplash() {
        let logged = UserDefaults.standard.bool(forKey: key)

        if !hasSeenOnboarding {
            appState = .onboarding
        } else {
            appState = logged ? .authenticated : .unauthenticated
        }
    }

    /// ✅ Login
    func login() {
        UserDefaults.standard.set(true, forKey: key)
        appState = .authenticated
    }

    /// 🚪 Logout
    func logout() {
        UserDefaults.standard.set(false, forKey: key)
        appState = .unauthenticated
    }

    /// 🔚 Fin de l’onboarding
    func finishOnboarding() {
        hasSeenOnboarding = true
        decideNextAfterSplash()
    }
}
