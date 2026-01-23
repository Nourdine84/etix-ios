import Foundation
import UIKit

final class TicketPDFExportViewModel: ObservableObject {

    @Published var pdfData: Data?
    @Published var showShareSheet = false
    @Published var isExporting = false

    func export(tickets: [Ticket]) {
        isExporting = true

        DispatchQueue.global(qos: .userInitiated).async {
            let pdf = self.generatePDF(from: tickets)

            DispatchQueue.main.async {
                self.pdfData = pdf
                self.showShareSheet = true
                self.isExporting = false
            }
        }
    }

    private func generatePDF(from tickets: [Ticket]) -> Data {
        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: 595, height: 842)
        )

        return renderer.pdfData { ctx in
            ctx.beginPage()
            var y: CGFloat = 40

            let title = NSAttributedString(
                string: "Historique des tickets",
                attributes: [.font: UIFont.boldSystemFont(ofSize: 22)]
            )
            title.draw(at: CGPoint(x: 40, y: y))
            y += 40

            for t in tickets {
                let line = "\(t.storeName) – \(t.category) – \(String(format: "%.2f €", t.amount))"
                let text = NSAttributedString(
                    string: line,
                    attributes: [.font: UIFont.systemFont(ofSize: 14)]
                )
                text.draw(at: CGPoint(x: 40, y: y))
                y += 20
            }
        }
    }
}
