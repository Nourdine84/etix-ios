//
//  eTixTests.swift
//  eTixTests
//

import Testing
@testable import eTix

struct ReceiptParserTests {

    @Test func amountOnTotalLineIsHighConfidence() {
        let r = ReceiptParser.parse("AUCHAN\nPain 1,20\nTOTAL 12,50 EUR")
        #expect(r.amount.value == 12.50)
        #expect(r.amount.confidence == .high)
    }

    @Test func amountFallbackIsLowConfidence() {
        let r = ReceiptParser.parse("AUCHAN\nArticle 3,40")
        #expect(r.amount.value == 3.40)
        #expect(r.amount.confidence == .low)
    }

    @Test func commaAndDotDecimalsBothParsed() {
        #expect(ReceiptParser.parse("TOTAL 9,99").amount.value == 9.99)
        #expect(ReceiptParser.parse("TOTAL 9.99").amount.value == 9.99)
    }

    @Test func storeNameFromTopLineIsMediumConfidence() {
        let r = ReceiptParser.parse("Carrefour City\n12/03/2024\nTOTAL 5,00")
        #expect(r.storeName.value == "Carrefour City")
        #expect(r.storeName.confidence == .medium)
    }

    @Test func noPhantomStoreFromNumericNoise() {
        // Bruit non exploitable : plus de repli lines.first → aucun nom fantôme,
        // et le résultat reste vide (écran « Aucune information détectée »).
        let r = ReceiptParser.parse("123")
        #expect(r.storeName.value == nil)
        #expect(r.isEmpty)
    }

    @Test func dateRecognizedIsHighConfidence() {
        let r = ReceiptParser.parse("Magasin\n05/01/2024\nTOTAL 5,00")
        #expect(r.date.value != nil)
        #expect(r.date.confidence == .high)
    }

    @Test func emptyTextYieldsNoneEverywhere() {
        let r = ReceiptParser.parse("")
        #expect(r.amount.value == nil)
        #expect(r.amount.confidence == .none)
        #expect(r.date.confidence == .none)
        #expect(r.storeName.confidence == .none)
    }

    @Test func missingValueForcesNoneConfidence() {
        // Invariant : une valeur nil impose toujours .none, même si on tente .high
        let field = OCRField<String>(value: nil, confidence: .high)
        #expect(field.confidence == .none)
    }
}

struct AmountParserTests {

    @Test func commaIsNormalized() {
        #expect(AmountParser.parse("12,50") == 12.50)
    }

    @Test func dotStillWorks() {
        #expect(AmountParser.parse("12.50") == 12.50)
    }

    @Test func surroundingWhitespaceTrimmed() {
        #expect(AmountParser.parse("  9,99 ") == 9.99)
    }

    @Test func zeroRejected() {
        #expect(AmountParser.parse("0") == nil)
    }

    @Test func negativeRejected() {
        #expect(AmountParser.parse("-5,00") == nil)
    }

    @Test func emptyRejected() {
        #expect(AmountParser.parse("") == nil)
    }

    @Test func nonNumericRejected() {
        #expect(AmountParser.parse("abc") == nil)
    }
}

struct FieldConfidenceMappingTests {

    @Test func highMapsToVerified() {
        #expect(FieldConfidence(ocr: .high) == .verified)
    }

    @Test func mediumMapsToToVerify() {
        #expect(FieldConfidence(ocr: .medium) == .toVerify)
    }

    @Test func lowMapsToToVerify() {
        #expect(FieldConfidence(ocr: .low) == .toVerify)
    }

    @Test func noneMapsToNilNoBadge() {
        #expect(FieldConfidence(ocr: .none) == nil)
    }
}

struct OCRExtractedDataTests {

    @Test func emptyResultIsEmpty() {
        #expect(ReceiptParser.parse("").isEmpty)
    }

    @Test func resultWithAmountIsNotEmpty() {
        #expect(!ReceiptParser.parse("TOTAL 12,50").isEmpty)
    }
}

struct PDFExportServiceTests {

    @Test func singleTicketExportProducesNonEmptyPDF() throws {
        let context = PersistenceController.shared.container.viewContext
        let ticket = Ticket(context: context)
        ticket.storeName = "Auchan"
        ticket.amount = 87.50
        ticket.category = "Alimentation"
        ticket.dateMillis = 1_713_100_000_000
        defer { context.delete(ticket) }

        let data = try PDFExportService.exportTicket(ticket)
        #expect(!data.isEmpty)
    }
}
