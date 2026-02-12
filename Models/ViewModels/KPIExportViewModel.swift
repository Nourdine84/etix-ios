import Foundation

final class KPIExportViewModel: ObservableObject {

    @Published var fileURL: URL?
    @Published var showShareSheet = false
    @Published var isExporting = false

    func export(
        type: KPIType,
        tickets: [Ticket],
        total: Double,
        variation: Double
    ) {
        isExporting = true

        let csv = buildCSV(
            type: type,
            tickets: tickets,
            total: total,
            variation: variation
        )

        // ✅ FIX : rawValue au lieu de identifier
        let filename = "eTix_KPI_\(type.rawValue).csv"

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(filename)

        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            DispatchQueue.main.async {
                self.fileURL = url
                self.showShareSheet = true
                self.isExporting = false
            }
        } catch {
            DispatchQueue.main.async {
                self.isExporting = false
            }
        }
    }

    private func buildCSV(
        type: KPIType,
        tickets: [Ticket],
        total: Double,
        variation: Double
    ) -> String {

        var csv = "KPI;Valeur\n"
        csv += "Type;\(type.title)\n"
        csv += "Total;\(String(format: "%.2f", total))\n"
        csv += "Variation %;\(String(format: "%.2f", variation))\n\n"
        csv += "Magasin;Catégorie;Montant\n"

        for t in tickets {
            csv += "\(t.storeName ?? "Inconnu");\(t.category);\(t.amount)\n"
        }

        return csv
    }
}
