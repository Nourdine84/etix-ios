import Foundation

final class StoreExportViewModel: ObservableObject {

    @Published var isExporting = false
    @Published var showShareSheet = false
    @Published var exportedURL: URL?

    func export(
        storeName: String,
        tickets: [Ticket],
        total: Double
    ) {
        isExporting = true

        DispatchQueue.global(qos: .userInitiated).async {
            let csv = self.buildCSV(
                storeName: storeName,
                tickets: tickets,
                total: total
            )

            let filename = "eTix_Store_\(storeName).csv"
                .replacingOccurrences(of: " ", with: "_")

            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(filename)

            do {
                try csv.write(to: url, atomically: true, encoding: .utf8)

                DispatchQueue.main.async {
                    self.exportedURL = url
                    self.showShareSheet = true
                    self.isExporting = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isExporting = false
                }
            }
        }
    }

    // MARK: - CSV Builder
    private func buildCSV(
        storeName: String,
        tickets: [Ticket],
        total: Double
    ) -> String {

        var csv = "Magasin;\(storeName)\n"
        csv += "Total;\(String(format: "%.2f", total))\n"
        csv += "Nombre de tickets;\(tickets.count)\n\n"
        csv += "Date;Catégorie;Montant\n"

        for t in tickets {
            let date = Date(timeIntervalSince1970: TimeInterval(t.dateMillis) / 1000)
            let dateStr = DateFormatter.localizedString(
                from: date,
                dateStyle: .short,
                timeStyle: .none
            )

            csv += "\(dateStr);\(t.category);\(t.amount)\n"
        }

        return csv
    }
}
