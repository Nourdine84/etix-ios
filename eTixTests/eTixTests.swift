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

struct FinancialStateEngineTests {

    private func inputs(
        total: Double = 100,
        previous: Double = 100,
        count: Int = 10,
        budgetTense: Bool = false
    ) -> FinancialInputs {
        FinancialInputs(
            periodTotal: total,
            previousPeriodTotal: previous,
            allTimeTicketCount: count,
            budgetTense: budgetTense
        )
    }

    // MARK: Paliers de maturité (Progressive Intelligence)

    @Test func noDataIsWelcome() {
        #expect(FinancialStateEngine.evaluate(inputs(count: 0))
                == FinancialState(kind: .welcome, tone: .neutral))
    }

    @Test func fewTicketsIsBuilding() {
        #expect(FinancialStateEngine.evaluate(inputs(count: 2)).kind == .building)
    }

    @Test func noPreviousPeriodIsSteady() {
        #expect(FinancialStateEngine.evaluate(inputs(total: 100, previous: 0, count: 10)).kind == .steady)
    }

    // MARK: Tendance

    @Test func strongRiseIsHighSpending() {
        #expect(FinancialStateEngine.evaluate(inputs(total: 200, previous: 100)).kind == .highSpending)
    }

    @Test func clearDropIsSaving() {
        #expect(FinancialStateEngine.evaluate(inputs(total: 80, previous: 100)).kind == .saving)
    }

    @Test func slightRiseKind() {
        #expect(FinancialStateEngine.evaluate(inputs(total: 112, previous: 100)).kind == .slightRise)
    }

    @Test func moderateDropIsUnderControl() {
        #expect(FinancialStateEngine.evaluate(inputs(total: 95, previous: 100)).kind == .underControl)
    }

    @Test func nearFlatIsSteady() {
        #expect(FinancialStateEngine.evaluate(inputs(total: 103, previous: 100)).kind == .steady)
    }

    // MARK: L'état métier ne dépend pas QUE du delta

    @Test func budgetTenseEscalatesBeyondDelta() {
        let s = FinancialStateEngine.evaluate(inputs(total: 101, previous: 100, budgetTense: true))
        #expect(s.kind == .highSpending)
        #expect(s.tone == .attention)
    }

    // MARK: Altitude globale — l'API ne renvoie QUE kind + tone
    // (structurellement : ni catégorie, ni magasin, ni action).

    @Test func stateExposesOnlyGlobalKindAndTone() {
        let s = FinancialStateEngine.evaluate(inputs(total: 200, previous: 100))
        #expect(s == FinancialState(kind: .highSpending, tone: .attention))
    }
}
