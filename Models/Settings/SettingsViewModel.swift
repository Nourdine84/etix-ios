import Foundation
import CoreData

final class SettingsViewModel: ObservableObject {

    @Published var settings: AppSettings
    @Published var showResetAlert = false
    @Published var showExportSheet = false
    @Published var exportedFileURL: URL?

    init() {
        self.settings = AppSettings.load()
    }

    // MARK: - Actions

    func exportAllTickets(context: NSManagedObjectContext) {
        // Implémentation simplifiée
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("eTix_export.csv")

        try? "Export".write(to: url, atomically: true, encoding: .utf8)

        exportedFileURL = url
        showExportSheet = true
    }

    func resetDatabase(context: NSManagedObjectContext) {

        let request: NSFetchRequest<NSFetchRequestResult> = Ticket.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        try? context.execute(deleteRequest)
        try? context.save()
    }

    func persistChanges() {
        AppSettings.save(
            appearance: settings.appearance,
            defaultRange: settings.defaultRange
        )
    }
}
