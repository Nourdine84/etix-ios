import SwiftUI
import WidgetKit
import CoreData

@main
struct eTixApp: App {

    @StateObject private var persistence = PersistenceController.shared
    @StateObject private var session = SessionViewModel()
    @StateObject private var addTicketVM: AddTicketViewModel

    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("app.appearance")
    private var appearanceRaw: String = AppAppearance.system.rawValue

    init() {
        let context = PersistenceController.shared.container.viewContext
        _addTicketVM = StateObject(
            wrappedValue: AddTicketViewModel(context: context)
        )
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .environmentObject(session)
                .environmentObject(addTicketVM)
                .tint(Theme.primaryBlue)
                .preferredColorScheme(currentColorScheme)
                .onAppear {
                    WidgetSync.updateSnapshot(
                        context: persistence.container.viewContext
                    )
                }
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: Notification.Name.NSManagedObjectContextDidSave,
                        object: persistence.container.viewContext
                    )
                ) { _ in
                    WidgetSync.updateSnapshot(
                        context: persistence.container.viewContext
                    )
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        WidgetSync.updateSnapshot(
                            context: persistence.container.viewContext
                        )
                    }
                }
        }
    }

    // ✅ CETTE PROPRIÉTÉ DOIT ÊTRE EN DEHORS DE body
    private var currentColorScheme: ColorScheme? {
        switch AppAppearance(rawValue: appearanceRaw) {
        case .light:
            return .light
        case .dark:
            return .dark
        default:
            return nil
        }
    }
}
