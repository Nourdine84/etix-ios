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

// MARK: - History digest

private struct MockTicket: HistoryTicketData, Identifiable {
    let id: Int
    let storeName: String
    let amount: Double
    let dateMillis: Int64
    let category: String
    let ticketDescription: String?
}

struct HistoryDigestEngineTests {

    // Calendrier et « maintenant » figés → tests déterministes.
    private var cal: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Europe/Paris")!
        return c
    }
    private let now = Date(timeIntervalSince1970: 1_714_000_000) // 25 avr. 2024

    private func ms(dayOffset: Int, hour: Int = 12) -> Int64 {
        let start = cal.startOfDay(for: now)
        let day = cal.date(byAdding: .day, value: dayOffset, to: start)!
        let dated = cal.date(byAdding: .hour, value: hour, to: day)!
        return Int64(dated.timeIntervalSince1970 * 1000)
    }

    private func ticket(
        _ id: Int, _ store: String, _ amount: Double,
        dayOffset: Int, hour: Int = 12,
        category: String = "Alimentation", description: String? = nil
    ) -> MockTicket {
        MockTicket(id: id, storeName: store, amount: amount,
                   dateMillis: ms(dayOffset: dayOffset, hour: hour),
                   category: category, ticketDescription: description)
    }

    private func build(_ tickets: [MockTicket], _ query: HistoryQuery) -> HistoryDigest<MockTicket> {
        HistoryDigestEngine.build(tickets: tickets, query: query, now: now, calendar: cal)
    }

    // Ordre d'entrée = date décroissante (comme le FetchRequest).
    private var sample: [MockTicket] {
        [
            ticket(1, "Auchan",       79.0,  dayOffset: 0,  hour: 14),
            ticket(2, "Boulangerie",  3.5,   dayOffset: 0,  hour: 9, category: "Restaurant"),
            ticket(3, "Leroy Merlin", 130.0, dayOffset: -1, category: "Maison"),
            ticket(4, "Total",        60.0,  dayOffset: -8, category: "Carburant",
                   description: "plein sans plomb 95 garantie facture")
        ]
    }

    // MARK: Regroupement + labels

    @Test func emptyQueryGroupsByDayWithLabels() {
        let d = build(sample, HistoryQuery())
        #expect(d.sections.count == 3)
        #expect(d.sections[0].label == "Aujourd'hui")
        #expect(d.sections[1].label == "Hier")
        #expect(d.sections[2].label != "Aujourd'hui" && d.sections[2].label != "Hier")
        #expect(!d.isNarrowed)
    }

    @Test func dayTotalsSumPerDay() {
        let d = build(sample, HistoryQuery())
        #expect(d.sections[0].dayTotal == 82.5)  // 79 + 3.5
        #expect(d.sections[1].dayTotal == 130.0)
    }

    @Test func resultCountAndTotalCoverWholeSet() {
        let d = build(sample, HistoryQuery())
        #expect(d.resultCount == 4)
        #expect(d.resultTotal == 272.5)
    }

    // MARK: Recherche

    @Test func textMatchesStore() {
        let d = build(sample, HistoryQuery(text: "auchan"))
        #expect(d.resultCount == 1)
        #expect(d.sections.first?.rows.first?.item.storeName == "Auchan")
        #expect(d.isNarrowed)
    }

    @Test func textMatchesCategory() {
        let d = build(sample, HistoryQuery(text: "maison"))
        #expect(d.resultCount == 1)
        #expect(d.sections.first?.rows.first?.item.id == 3)
    }

    @Test func textMatchesDescriptionAndProducesSnippet() {
        let d = build(sample, HistoryQuery(text: "garantie"))
        #expect(d.resultCount == 1)
        let row = d.sections.first?.rows.first
        #expect(row?.item.id == 4)
        #expect(row?.snippet != nil)
    }

    @Test func nonDescriptionMatchHasNoSnippet() {
        let d = build(sample, HistoryQuery(text: "auchan"))
        #expect(d.sections.first?.rows.first?.snippet == nil)
    }

    // MARK: Filtres

    @Test func amountFilterMinMax() {
        let d = build(sample, HistoryQuery(minAmount: 50, maxAmount: 100))
        #expect(d.resultCount == 2)                     // 79 et 60
        #expect(Set(d.sections.flatMap { $0.rows.map { $0.item.id } }) == [1, 4])
    }

    @Test func categoryFilter() {
        let d = build(sample, HistoryQuery(categories: ["Maison"]))
        #expect(d.resultCount == 1)
        #expect(d.sections.first?.rows.first?.item.id == 3)
    }

    @Test func storeFilter() {
        let d = build(sample, HistoryQuery(stores: ["Total"]))
        #expect(d.resultCount == 1)
        #expect(d.sections.first?.rows.first?.item.id == 4)
    }

    @Test func periodFilterExcludesOutside() {
        var q = HistoryQuery()
        q.startDate = cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: now)) // hier → aujourd'hui
        let d = build(sample, q)
        #expect(d.resultCount == 3)                     // exclut le ticket 4 (J-8)
    }

    // MARK: Tri

    @Test func recentFirstPreservesFetchOrder() {
        let d = build(sample, HistoryQuery(sort: .recentFirst))
        #expect(d.sections.first?.label == "Aujourd'hui")
        // Rangées du jour 0 dans l'ordre d'entrée (14h avant 9h).
        #expect(d.sections[0].rows.map { $0.item.id } == [1, 2])
    }

    @Test func oldestFirstReversesOrder() {
        let d = build(sample, HistoryQuery(sort: .oldestFirst))
        #expect(d.sections.first?.rows.first?.item.id == 4)   // le plus ancien d'abord
        #expect(d.sections.last?.label == "Aujourd'hui")
    }

    @Test func amountDescSurfacesHighestDayFirstAndOrdersRows() {
        let d = build(sample, HistoryQuery(sort: .amountDesc))
        // Le plus gros montant (130, J-1) fait apparaître son jour en premier.
        #expect(d.sections.first?.rows.first?.item.amount == 130.0)
        // Jour 0 : 79 avant 3.5.
        let today = d.sections.first(where: { $0.label == "Aujourd'hui" })
        #expect(today?.rows.map { $0.item.amount } == [79.0, 3.5])
    }

    @Test func amountAscOrdersRowsAscending() {
        let d = build(sample, HistoryQuery(sort: .amountAsc))
        #expect(d.sections.first?.rows.first?.item.amount == 3.5)
    }

    // MARK: isNarrowed

    @Test func sortAloneDoesNotNarrow() {
        #expect(!HistoryQuery(sort: .amountDesc).isNarrowed)
        #expect(HistoryQuery(minAmount: 10).isNarrowed)
    }

    @Test func emptyInputYieldsNoSections() {
        let d = build([], HistoryQuery(text: "x"))
        #expect(d.sections.isEmpty)
        #expect(d.resultCount == 0)
        #expect(d.resultTotal == 0)
    }
}
