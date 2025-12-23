import Foundation
import CoreGraphics
import UIKit
import CoreData

enum PDFExportError: Error {
    case noTickets
    case failedToGenerate
}

struct PDFExportService {

    /// Génère un PDF "premium" pour les tickets du mois courant
    /// - Parameter context: NSManagedObjectContext Core Data
    /// - Returns: Data du PDF à partager / sauvegarder
    static func exportCurrentMonthTickets(context: NSManagedObjectContext) throws -> Data {
        let cal = Calendar.current
        let now = Date()
        let comps = cal.dateComponents([.year, .month], from: now)
        let monthStart = cal.date(from: comps) ?? now
        let monthEnd = now

        let tickets = try fetchTickets(from: monthStart, to: monthEnd, context: context)
        guard !tickets.isEmpty else { throw PDFExportError.noTickets }

        let total = tickets.reduce(0.0) { $0 + $1.amount }
        let count = tickets.count

        return try generatePDF(
            for: tickets,
            monthStart: monthStart,
            monthEnd: monthEnd,
            total: total,
            count: count
        )
    }

    // MARK: - Fetch

    private static func fetchTickets(from start: Date,
                                     to end: Date,
                                     context: NSManagedObjectContext) throws -> [Ticket] {
        let startMs = Int64(start.timeIntervalSince1970 * 1000)
        let endMs   = Int64(end.timeIntervalSince1970 * 1000)

        let req = NSFetchRequest<Ticket>(entityName: "Ticket")
        req.predicate = NSPredicate(format: "dateMillis >= %lld AND dateMillis <= %lld", startMs, endMs)
        req.sortDescriptors = [NSSortDescriptor(key: "dateMillis", ascending: true)]

        return try context.fetch(req)
    }

    // MARK: - PDF Premium

    private static func generatePDF(for tickets: [Ticket],
                                    monthStart: Date,
                                    monthEnd: Date,
                                    total: Double,
                                    count: Int) throws -> Data {

        let pdfMetaData: [CFString: Any] = [
            kCGPDFContextCreator: "eTix",
            kCGPDFContextAuthor: "eTix",
            kCGPDFContextTitle: "Export des tickets - eTix"
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        // A4
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            var currentY: CGFloat = 0
            let leftMargin: CGFloat = 32
            let rightMargin: CGFloat = 32
            let lineHeight: CGFloat = 18

            func startNewPage() {
                context.beginPage()
                currentY = 0
                currentY = drawHeader(in: pageRect,
                                      currentY: currentY,
                                      leftMargin: leftMargin,
                                      rightMargin: rightMargin,
                                      monthStart: monthStart,
                                      monthEnd: monthEnd,
                                      total: total,
                                      count: count)
                currentY += 16
                drawTableHeader(y: currentY, leftMargin: leftMargin, rightMargin: rightMargin)
                currentY += 28
            }

            startNewPage()

            for ticket in tickets {
                if currentY + lineHeight + 40 > pageRect.height {
                    startNewPage()
                }
                drawTicketRow(ticket,
                              y: currentY,
                              leftMargin: leftMargin,
                              rightMargin: rightMargin)
                currentY += lineHeight + 6
            }

            // Footer sur la dernière page
            drawFooter(in: pageRect,
                       leftMargin: leftMargin,
                       rightMargin: rightMargin,
                       bottomPadding: 24)
        }

        guard !data.isEmpty else { throw PDFExportError.failedToGenerate }
        return data
    }

    // MARK: - Header Premium

    /// Dessine le header complet (logo + titre + résumé)
    @discardableResult
    private static func drawHeader(in rect: CGRect,
                                   currentY: CGFloat,
                                   leftMargin: CGFloat,
                                   rightMargin: CGFloat,
                                   monthStart: Date,
                                   monthEnd: Date,
                                   total: Double,
                                   count: Int) -> CGFloat {

        var y = currentY

        // Bandeau de couleur en haut
        let headerHeight: CGFloat = 80
        let headerRect = CGRect(x: 0, y: y, width: rect.width, height: headerHeight)
        let context = UIGraphicsGetCurrentContext()
        let etixBlue = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)

        context?.setFillColor(etixBlue.cgColor)
        context?.fill(headerRect)

        // Logo ou icône + titre
        let iconSize: CGFloat = 40
        let iconRect = CGRect(x: leftMargin,
                              y: y + (headerHeight - iconSize) / 2,
                              width: iconSize,
                              height: iconSize)

        if let logo = UIImage(named: "eTixLogo") {
            logo.draw(in: iconRect)
        } else {
            // Icône fallback
            let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .semibold)
            if let ticketIcon = UIImage(systemName: "ticket.fill", withConfiguration: config) {
                let symbolRect = iconRect
                ticketIcon.withTintColor(.white, renderingMode: .alwaysOriginal)
                    .draw(in: symbolRect)
            }
        }

        let title = "Export des tickets"
        let subtitle = "Application eTix"

        let titleParagraph = NSMutableParagraphStyle()
        titleParagraph.alignment = .left

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
            .foregroundColor: UIColor.white,
            .paragraphStyle: titleParagraph
        ]

        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.white.withAlphaComponent(0.9),
            .paragraphStyle: titleParagraph
        ]

        let textX = iconRect.maxX + 10
        let titleRect = CGRect(x: textX,
                               y: iconRect.minY,
                               width: rect.width - textX - rightMargin,
                               height: 22)
        let subRect = CGRect(x: textX,
                             y: titleRect.maxY + 2,
                             width: rect.width - textX - rightMargin,
                             height: 18)

        title.draw(in: titleRect, withAttributes: titleAttrs)
        subtitle.draw(in: subRect, withAttributes: subAttrs)

        y += headerHeight + 16

        // Résumé du mois dans un "card"
        let cardRect = CGRect(x: leftMargin,
                              y: y,
                              width: rect.width - leftMargin - rightMargin,
                              height: 70)

        let cardPath = UIBezierPath(roundedRect: cardRect, cornerRadius: 10)
        UIColor(white: 0.96, alpha: 1.0).setFill()
        cardPath.fill()

        let _ = Calendar.current
        let df = DateFormatter()
        df.locale = .current
        df.setLocalizedDateFormatFromTemplate("MMM yyyy")
        let monthLabel = df.string(from: monthStart).capitalized

        let rangeDf = DateFormatter()
        rangeDf.locale = .current
        rangeDf.dateStyle = .short

        let rangeLabel = "\(rangeDf.string(from: monthStart)) – \(rangeDf.string(from: monthEnd))"

        let bold13 = UIFont.systemFont(ofSize: 13, weight: .semibold)
        let regular12 = UIFont.systemFont(ofSize: 12, weight: .regular)

        let colWidth = cardRect.width / 3

        // Colonne 1 : Mois
        let col1Rect = CGRect(x: cardRect.minX + 10,
                              y: cardRect.minY + 10,
                              width: colWidth - 10,
                              height: 50)
        let col1Title = "Mois"
        let col1Value = monthLabel

        col1Title.draw(in: col1Rect,
                       withAttributes: [
                        .font: regular12,
                        .foregroundColor: UIColor.darkGray
                       ])

        let col1ValueRect = CGRect(x: col1Rect.minX,
                                   y: col1Rect.minY + 18,
                                   width: col1Rect.width,
                                   height: 20)
        col1Value.draw(in: col1ValueRect,
                       withAttributes: [
                        .font: bold13,
                        .foregroundColor: UIColor.black
                       ])

        // Colonne 2 : Tickets
        let col2Rect = CGRect(x: col1Rect.maxX,
                              y: col1Rect.minY,
                              width: colWidth - 10,
                              height: 50)
        let col2Title = "Tickets"
        let col2Value = "\(count)"

        col2Title.draw(in: col2Rect,
                       withAttributes: [
                        .font: regular12,
                        .foregroundColor: UIColor.darkGray
                       ])
        let col2ValueRect = CGRect(x: col2Rect.minX,
                                   y: col2Rect.minY + 18,
                                   width: col2Rect.width,
                                   height: 20)
        col2Value.draw(in: col2ValueRect,
                       withAttributes: [
                        .font: bold13,
                        .foregroundColor: UIColor.black
                       ])

        // Colonne 3 : Total
        let col3Rect = CGRect(x: col2Rect.maxX,
                              y: col1Rect.minY,
                              width: colWidth - 10,
                              height: 50)
        let col3Title = "Total"
        let col3Value = String(format: "%.2f €", total)

        col3Title.draw(in: col3Rect,
                       withAttributes: [
                        .font: regular12,
                        .foregroundColor: UIColor.darkGray
                       ])
        let col3ValueRect = CGRect(x: col3Rect.minX,
                                   y: col3Rect.minY + 18,
                                   width: col3Rect.width,
                                   height: 20)
        col3Value.draw(in: col3ValueRect,
                       withAttributes: [
                        .font: bold13,
                        .foregroundColor: UIColor.black
                       ])

        // Sous-ligne période
        let periodRect = CGRect(x: cardRect.minX + 10,
                                y: cardRect.maxY - 18,
                                width: cardRect.width - 20,
                                height: 14)
        let periodAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.gray
        ]
        rangeLabel.draw(in: periodRect, withAttributes: periodAttrs)

        y = cardRect.maxY + 24
        return y
    }

    // MARK: - Table

    private static func drawTableHeader(y: CGFloat,
                                        leftMargin: CGFloat,
                                        rightMargin: CGFloat) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
            .paragraphStyle: paragraph
        ]

        let width = 595 - leftMargin - rightMargin
        let storeWidth = width * 0.30
        let dateWidth = width * 0.20
        let catWidth  = width * 0.25
        let amountWidth = width * 0.25

        let storeRect  = CGRect(x: leftMargin, y: y, width: storeWidth, height: 18)
        let dateRect   = CGRect(x: storeRect.maxX, y: y, width: dateWidth, height: 18)
        let catRect    = CGRect(x: dateRect.maxX, y: y, width: catWidth, height: 18)
        let amountRect = CGRect(x: catRect.maxX, y: y, width: amountWidth, height: 18)

        "Magasin".draw(in: storeRect, withAttributes: attrs)
        "Date".draw(in: dateRect, withAttributes: attrs)
        "Catégorie".draw(in: catRect, withAttributes: attrs)

        var rightAligned = attrs
        let rightParagraph = NSMutableParagraphStyle()
        rightParagraph.alignment = .right
        rightAligned[.paragraphStyle] = rightParagraph

        "Montant".draw(in: amountRect, withAttributes: rightAligned)

        // Ligne sous le header
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.lightGray.cgColor)
        context?.setLineWidth(0.5)
        context?.move(to: CGPoint(x: leftMargin, y: y + 20))
        context?.addLine(to: CGPoint(x: leftMargin + width, y: y + 20))
        context?.strokePath()
    }

    private static func drawTicketRow(_ ticket: Ticket,
                                      y: CGFloat,
                                      leftMargin: CGFloat,
                                      rightMargin: CGFloat) {
        let width = 595 - leftMargin - rightMargin
        let storeWidth = width * 0.30
        let dateWidth = width * 0.20
        let catWidth  = width * 0.25
        let amountWidth = width * 0.25

        let storeRect  = CGRect(x: leftMargin, y: y, width: storeWidth, height: 18)
        let dateRect   = CGRect(x: storeRect.maxX, y: y, width: dateWidth, height: 18)
        let catRect    = CGRect(x: dateRect.maxX, y: y, width: catWidth, height: 18)
        let amountRect = CGRect(x: catRect.maxX, y: y, width: amountWidth, height: 18)

        let pLeft = NSMutableParagraphStyle()
        pLeft.alignment = .left

        let baseAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .paragraphStyle: pLeft
        ]

        let storeName = ticket.storeName
        let category  = ticket.category

        let df = DateFormatter()
        df.locale = .current
        df.dateStyle = .short
        let date = Date(timeIntervalSince1970: TimeInterval(ticket.dateMillis) / 1000.0)
        let dateText = df.string(from: date)

        storeName.draw(in: storeRect, withAttributes: baseAttrs)
        dateText.draw(in: dateRect, withAttributes: baseAttrs)
        category.draw(in: catRect, withAttributes: baseAttrs)

        let pRight = NSMutableParagraphStyle()
        pRight.alignment = .right
        var amountAttrs = baseAttrs
        amountAttrs[.paragraphStyle] = pRight

        let amountText = String(format: "%.2f €", ticket.amount)
        amountText.draw(in: amountRect, withAttributes: amountAttrs)
    }

    // MARK: - Footer

    private static func drawFooter(in rect: CGRect,
                                   leftMargin: CGFloat,
                                   rightMargin: CGFloat,
                                   bottomPadding: CGFloat) {
        let footerText = "Généré avec l’application eTix"
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9),
            .foregroundColor: UIColor.gray,
            .paragraphStyle: paragraph
        ]

        let footerRect = CGRect(
            x: leftMargin,
            y: rect.height - bottomPadding,
            width: rect.width - leftMargin - rightMargin,
            height: 12
        )

        footerText.draw(in: footerRect, withAttributes: attrs)
    }
}
