import Foundation
import SwiftUI
import CoreData
import UIKit

final class SettingsViewModel: ObservableObject {

    @Published var settings: AppSettings

    @Published var showResetAlert = false
    @Published var showExportSheet = false
    @Published var exportedFileURL: URL?

    init() {
        self.settings = AppSettings()
    }

    // MARK: - CSV

    func exportAllTickets(context: NSManagedObjectContext) {

        let request = Ticket.fetchAllRequest()

        do {
            let tickets = try context.fetch(request)

            var csv = "Magasin;Catégorie;Montant;Date\n"

            for t in tickets {
                let date = Date(timeIntervalSince1970: TimeInterval(t.dateMillis) / 1000)
                let dateString = DateFormatter.localizedString(
                    from: date,
                    dateStyle: .short,
                    timeStyle: .none
                )

                csv += "\(t.storeName);\(t.category);\(t.amount);\(dateString)\n"
            }

            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("eTix_All_Tickets.csv")

            try csv.write(to: url, atomically: true, encoding: .utf8)

            exportedFileURL = url
            showExportSheet = true

        } catch {
            print("CSV error:", error)
        }
    }

    // MARK: - PDF

    func exportAllTicketsPDF(context: NSManagedObjectContext) {

        let request = Ticket.fetchAllRequest()

        do {
            let tickets = try context.fetch(request)

            let renderer = UIGraphicsPDFRenderer(
                bounds: CGRect(x: 0, y: 0, width: 595, height: 842)
            )

            let data = renderer.pdfData { ctx in
                ctx.beginPage()

                var y: CGFloat = 40

                for ticket in tickets {

                    let date = Date(timeIntervalSince1970: TimeInterval(ticket.dateMillis) / 1000)
                    let dateString = DateFormatter.localizedString(
                        from: date,
                        dateStyle: .short,
                        timeStyle: .none
                    )

                    let line = "\(dateString) – \(ticket.storeName) – \(ticket.category) – \(String(format: "%.2f €", ticket.amount))"

                    line.draw(
                        at: CGPoint(x: 40, y: y),
                        withAttributes: [.font: UIFont.systemFont(ofSize: 12)]
                    )

                    y += 18
                }
            }

            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("eTix_All_Tickets.pdf")

            try data.write(to: url)

            exportedFileURL = url
            showExportSheet = true

        } catch {
            print("PDF error:", error)
        }
    }

    // MARK: - RESET

    func resetDatabase(context: NSManagedObjectContext) {

        let request = Ticket.fetchAllRequest()

        do {
            let tickets = try context.fetch(request)

            for ticket in tickets {
                context.delete(ticket)
            }

            try context.save()

        } catch {
            print("Reset error:", error)
        }
    }
}
