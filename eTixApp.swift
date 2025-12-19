import SwiftUI
import WidgetKit
import CoreData

@main
struct eTixApp: App {
    @StateObject private var persistence = PersistenceController.shared
    @StateObject private var session = SessionViewModel()
    @StateObject private var addTicketVM: AddTicketViewModel

    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("app.appearance") private var appearanceRaw: String = AppAppearance.default.rawValue

    init() {
        let context = PersistenceController.shared.container.viewContext
        _addTicketVM = StateObject(wrappedValue: AddTicketViewModel(context: context))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .environmentObject(session)
                .environmentObject(addTicketVM)
                .tint(Theme.primaryBlue)
                .preferredColorScheme(AppAppearance(rawValue: appearanceRaw)?.colorScheme)
                // 1) Snapshot initial au lancement
                .onAppear {
                    WidgetSync.updateSnapshot(context: persistence.container.viewContext)
                }
                // 2) Snapshot à chaque sauvegarde Core Data de ce contexte
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: Notification.Name.NSManagedObjectContextDidSave,
                        object: persistence.container.viewContext
                    )
                ) { _ in
                    WidgetSync.updateSnapshot(context: persistence.container.viewContext)
                }
                // 3) Snapshot quand l’app revient active (utile si widget est visible)
                .onChange(of: scenePhase) { phase in
                    if phase == .active {
                        WidgetSync.updateSnapshot(context: persistence.container.viewContext)
                    }
                }
        }
    }
}

struct RootView: View {
    @EnvironmentObject var session: SessionViewModel

    var body: some View {
        Group {
            switch session.appState {
            case .splash:
                SplashView()
                    .onAppear {
                        // On laisse le Splash s’afficher puis on décide où aller
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            session.decideNextAfterSplash()
                        }
                    }
            case .onboarding:
                OnboardingView()
            case .unauthenticated:
                LoginView()
            case .authenticated:
                MainView()
            }
        }
    }
}
