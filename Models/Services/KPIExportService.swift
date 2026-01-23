import UIKit
import PDFKit

enum KPIExportService {

    static func exportKPI(
        type: KPIType,
        tickets: [Ticket],
        total: Double,
        variation: Double
    ) -> URL? {

        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("KPI-\(type.title).pdf")

        do {
            try renderer.writePDF(to: url) { ctx in
                ctx.beginPage()

                let titleAttr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 22)
                ]

                let bodyAttr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14)
                ]

                "KPI – \(type.title)"
                    .draw(at: CGPoint(x: 40, y: 40), withAttributes: titleAttr)

                let body = """
                Total : \(String(format: "%.2f €", total))
                Variation : \(String(format: "%.1f %%", variation))
                Tickets : \(tickets.count)
                """

                body.draw(
                    in: CGRect(x: 40, y: 90, width: 500, height: 200),
                    withAttributes: bodyAttr
                )
            }
            return url
        } catch {
            print("❌ KPI export error:", error)
            return nil
        }
    }
}
