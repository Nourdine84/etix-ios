import UIKit
import PDFKit

final class KPIExportService {

    static func export(
        title: String,
        tickets: [Ticket],
        total: Double
    ) -> URL? {

        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("eTix-\(title).pdf")

        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()

                var y: CGFloat = 40

                // Title
                let titleAttr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 22)
                ]
                title.draw(at: CGPoint(x: 40, y: y), withAttributes: titleAttr)
                y += 36

                // Total
                let totalText = String(format: "Total : %.2f €", total)
                totalText.draw(
                    at: CGPoint(x: 40, y: y),
                    withAttributes: [.font: UIFont.systemFont(ofSize: 16)]
                )
                y += 30

                // Tickets
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium

                for ticket in tickets {
                    if y > 780 {
                        context.beginPage()
                        y = 40
                    }

                    let date = Date(timeIntervalSince1970: TimeInterval(ticket.dateMillis) / 1000)
                    let line = "\(dateFormatter.string(from: date)) – \(ticket.storeName) – \(ticket.category) – \(String(format: "%.2f €", ticket.amount))"

                    line.draw(
                        at: CGPoint(x: 40, y: y),
                        withAttributes: [.font: UIFont.systemFont(ofSize: 12)]
                    )
                    y += 18
                }
            }
            return url
        } catch {
            print("❌ PDF export error:", error)
            return nil
        }
    }
}
