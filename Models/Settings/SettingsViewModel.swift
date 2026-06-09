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
        let request = Ticket.fetchAllRequest()
        guard let tickets = try? context.fetch(request) else { return }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .short
        formatter.timeStyle = .none

        var csv = "Date,Magasin,Montant (€),Catégorie,Description\n"
        for ticket in tickets {
            let date = formatter.string(from: Date(timeIntervalSince1970: Double(ticket.dateMillis) / 1000))
            let store = ticket.storeName.csvEscaped
            let amount = String(format: "%.2f", ticket.amount)
            let category = ticket.category.csvEscaped
            let description = (ticket.ticketDescription ?? "").csvEscaped
            csv += "\(date),\(store),\(amount),\(category),\(description)\n"
        }

        let filename = "eTix_export_\(Int(Date().timeIntervalSince1970)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        guard (try? csv.write(to: url, atomically: true, encoding: .utf8)) != nil else { return }

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

private extension String {
    var csvEscaped: String {
        if contains(",") || contains("\"") || contains("\n") {
            return "\"" + replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return self
    }
}
