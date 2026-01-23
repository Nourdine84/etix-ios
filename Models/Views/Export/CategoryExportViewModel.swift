import Foundation
import CoreData

final class CategoryExportViewModel: ObservableObject {

    @Published var isExporting = false
    @Published var exportedURL: URL?
    @Published var showShareSheet = false
    @Published var errorMessage: String?

    func export(
        categoryName: String,
        tickets: [Ticket],
        total: Double
    ) {
        isExporting = true

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let csv = self.buildCSV(
                    category: categoryName,
                    tickets: tickets,
                    total: total
                )

                let filename = "eTix_Category_\(categoryName).csv"
                    .replacingOccurrences(of: " ", with: "_")

                let url = FileManager.default.temporaryDirectory
                    .appendingPathComponent(filename)

                try csv.write(to: url, atomically: true, encoding: .utf8)

                DispatchQueue.main.async {
                    self.exportedURL = url
                    self.showShareSheet = true
                    self.isExporting = false
                }

            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isExporting = false
                }
            }
        }
    }

    // MARK: - CSV builder
    private func buildCSV(
        category: String,
        tickets: [Ticket],
        total: Double
    ) -> String {

        var csv = "Catégorie;\(category)\n"
        csv += "Total;\(String(format: "%.2f", total))\n"
        csv += "Nombre de tickets;\(tickets.count)\n\n"

        csv += "Date;Magasin;Montant\n"

        for t in tickets {
            let date = Date(timeIntervalSince1970: TimeInterval(t.dateMillis) / 1000)
            let dateStr = DateFormatter.localizedString(
                from: date,
                dateStyle: .short,
                timeStyle: .none
            )

            csv += "\(dateStr);\(t.storeName);\(String(format: "%.2f", t.amount))\n"
        }

        return csv
    }
}
