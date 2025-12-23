import SwiftUI
import Foundation

final class SessionViewModel: ObservableObject {

    enum AppState {
        case splash
        case onboarding
        case unauthenticated
        case authenticated
    }

    // MARK: - Published
    @Published var appState: AppState = .splash

    // MARK: - Storage keys
    private static let loginKey = "isLoggedIn"

    @AppStorage("app.hasSeenOnboarding")
    var hasSeenOnboarding: Bool = false

    // MARK: - Init
    init() {
        // Splash court puis décision
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { [weak self] in
            self?.decideNextAfterSplash()
        }
    }

    // MARK: - Navigation logic
    func decideNextAfterSplash() {
        let logged = UserDefaults.standard.bool(forKey: Self.loginKey)

        if !hasSeenOnboarding {
            appState = .onboarding
        } else {
            appState = logged ? .authenticated : .unauthenticated
        }
    }

    // MARK: - Auth
    func login() {
        UserDefaults.standard.set(true, forKey: Self.loginKey)
        appState = .authenticated
    }

    func logout() {
        UserDefaults.standard.set(false, forKey: Self.loginKey)
        appState = .unauthenticated
    }

    // MARK: - Onboarding
    func finishOnboarding() {
        hasSeenOnboarding = true
        decideNextAfterSplash()
    }
}
