import Foundation

final class StoreExportViewModel: ObservableObject {

    @Published var isExporting = false
    @Published var showShareSheet = false
    @Published var exportURL: URL?

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
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(filename)

            try? csv.write(to: url, atomically: true, encoding: .utf8)

            DispatchQueue.main.async {
                self.exportURL = url
                self.showShareSheet = true
                self.isExporting = false
            }
        }
    }

    private func buildCSV(
        storeName: String,
        tickets: [Ticket],
        total: Double
    ) -> String {

        var csv = "Magasin;\(storeName)\n"
        csv += "Total;\(String(format: "%.2f", total))\n\n"
        csv += "Date;Catégorie;Montant\n"

        for t in tickets {
            let date = DateUtils.shortString(fromMillis: t.dateMillis)
            csv += "\(date);\(t.category);\(t.amount)\n"
        }

        return csv
    }
}
