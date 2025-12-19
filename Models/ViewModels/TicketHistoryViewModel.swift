import Foundation
import CoreData
import SwiftUI

final class TicketExportViewModel: ObservableObject {
    @Published var isExporting: Bool = false
    @Published var exportError: String?
    @Published var pdfData: Data?
    @Published var showShareSheet: Bool = false

    func exportCurrentMonth(context: NSManagedObjectContext) {
        isExporting = true
        exportError = nil

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try PDFExportService.exportCurrentMonthTickets(context: context)
                DispatchQueue.main.async {
                    self.pdfData = data
                    self.isExporting = false
                    self.showShareSheet = true
                }
            } catch PDFExportError.noTickets {
                DispatchQueue.main.async {
                    self.isExporting = false
                    self.exportError = "Aucun ticket pour ce mois."
                }
            } catch {
                DispatchQueue.main.async {
                    self.isExporting = false
                    self.exportError = "Erreur lors de la génération du PDF."
                }
            }
        }
    }
}
