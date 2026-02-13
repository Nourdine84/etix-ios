import Foundation
import SwiftUI
import CoreData
import UIKit

final class SettingsViewModel: ObservableObject {

    // MARK: - Published UI State

    @Published var settings = AppSettings()

    @Published var showResetAlert: Bool = false
    @Published var showExportSheet: Bool = false

    @Published var exportedFileURL: URL?
    @Published var isExporting: Bool = false

    // MARK: - Export CSV Global

    func exportAllTickets(context: NSManagedObjectContext) {

        isExporting = true

        let request = Ticket.fetchAllRequest()

        do {
            let tickets = try context.fetch(request)

            var csv = "Magasin;Catégorie;Montant;Date\n"

            for t in tickets {
                let date = Date(
                    timeIntervalSince1970: TimeInterval(t.dateMillis) / 1000
                )

                let dateString = DateFormatter.localizedString(
                    from: date,
                    dateStyle: .short,
                    timeStyle: .none
                )

                csv += "\(t.storeName);\(t.category);\(t.amount);\(dateString)\n"
            }

            let filename = "eTix_All_Tickets.csv"
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(filename)

            try csv.write(to: url, atomically: true, encoding: .utf8)

            DispatchQueue.main.async {
                self.exportedFileURL = url
                self.showExportSheet = true
                self.isExporting = false
            }

        } catch {
            DispatchQueue.main.async {
                self.isExporting = false
            }
            print("Erreur export CSV :", error)
        }
    }

    // MARK: - Export PDF Global

    func exportAllTicketsPDF(context: NSManagedObjectContext) {

        isExporting = true

        let request = Ticket.fetchAllRequest()

        do {
            let tickets = try context.fetch(request)

            let renderer = UIGraphicsPDFRenderer(
                bounds: CGRect(x: 0, y: 0, width: 595, height: 842)
            )

            let data = renderer.pdfData { ctx in
                ctx.beginPage()

                var y: CGFloat = 40

                let title = "Export complet eTix"
                title.draw(at: CGPoint(x: 40, y: y), withAttributes: [
                    .font: UIFont.boldSystemFont(ofSize: 20)
                ])

                y += 40

                for ticket in tickets {

                    let date = Date(
                        timeIntervalSince1970: TimeInterval(ticket.dateMillis) / 1000
                    )

                    let dateString = DateFormatter.localizedString(
                        from: date,
                        dateStyle: .short,
                        timeStyle: .none
                    )

                    let line = "\(dateString) – \(ticket.storeName) – \(ticket.category) – \(String(format: "%.2f €", ticket.amount))"

                    line.draw(
                        at: CGPoint(x: 40, y: y),
                        withAttributes: [
                            .font: UIFont.systemFont(ofSize: 12)
                        ]
                    )

                    y += 18

                    if y > 800 {
                        ctx.beginPage()
                        y = 40
                    }
                }
            }

            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("eTix_All_Tickets.pdf")

            try data.write(to: url)

            DispatchQueue.main.async {
                self.exportedFileURL = url
                self.showExportSheet = true
                self.isExporting = false
            }

        } catch {
            DispatchQueue.main.async {
                self.isExporting = false
            }
            print("Erreur export PDF :", error)
        }
    }

    // MARK: - Reset complet

    func resetDatabase(context: NSManagedObjectContext) {

        let request = Ticket.fetchAllRequest()

        do {
            let tickets = try context.fetch(request)

            for ticket in tickets {
                context.delete(ticket)
            }

            try context.save()

        } catch {
            print("Erreur reset complet :", error)
        }
    }

    // MARK: - Reset sélectif par période

    func resetTickets(
        in range: TimeRange,
        context: NSManagedObjectContext
    ) {

        let r = DateRangeHelper.currentRange(for: range)
        let start = DateRangeHelper.millis(r.start)
        let end = DateRangeHelper.millis(r.end)

        let request = Ticket.fetchAllRequest()

        do {
            let tickets = try context.fetch(request)

            let filtered = tickets.filter {
                $0.dateMillis >= start && $0.dateMillis < end
            }

            for ticket in filtered {
                context.delete(ticket)
            }

            try context.save()

        } catch {
            print("Erreur reset sélectif :", error)
        }
    }
}
