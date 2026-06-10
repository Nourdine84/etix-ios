import Foundation
import CoreData

struct StoreCategoryMapper {

    // MARK: - Public API

    static func suggestCategory(for storeName: String, context: NSManagedObjectContext) -> String? {
        let name = storeName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return nil }
        return historySuggestion(for: name, context: context)
            ?? dictionarySuggestion(for: name)
    }

    // MARK: - History (most frequent user category for this store)

    private static func historySuggestion(for storeName: String, context: NSManagedObjectContext) -> String? {
        let request: NSFetchRequest<Ticket> = Ticket.fetchRequest()
        request.predicate = NSPredicate(format: "storeName ==[cd] %@", storeName)
        guard let tickets = try? context.fetch(request), !tickets.isEmpty else { return nil }

        return Dictionary(grouping: tickets) { $0.category }
            .mapValues { $0.count }
            .filter { !$0.key.isEmpty }
            .max { $0.value < $1.value }?
            .key
    }

    // MARK: - Dictionary (French stores → category)

    private static func dictionarySuggestion(for storeName: String) -> String? {
        let normalized = storeName
            .lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)

        for (keyword, category) in knownStores where normalized.contains(keyword) {
            return category
        }
        return nil
    }

    // MARK: - Known stores

    static let knownStores: [String: String] = [
        // Grande distribution
        "carrefour":      "Alimentation",
        "leclerc":        "Alimentation",
        "lidl":           "Alimentation",
        "aldi":           "Alimentation",
        "intermarche":    "Alimentation",
        "super u":        "Alimentation",
        "monoprix":       "Alimentation",
        "franprix":       "Alimentation",
        "picard":         "Alimentation",
        "biocoop":        "Alimentation",
        "naturalia":      "Alimentation",
        "auchan":         "Alimentation",
        "cora":           "Alimentation",
        "netto":          "Alimentation",

        // Restauration rapide
        "mcdonald":       "Restaurant",
        "mcdo":           "Restaurant",
        "burger king":    "Restaurant",
        "kfc":            "Restaurant",
        "subway":         "Restaurant",
        "domino":         "Restaurant",
        "pizza hut":      "Restaurant",
        "starbucks":      "Restaurant",
        "five guys":      "Restaurant",
        "paul":           "Alimentation",

        // Sport
        "decathlon":      "Sport",
        "go sport":       "Sport",
        "sport 2000":     "Sport",

        // Santé
        "pharmacie":      "Santé",
        "pharma":         "Santé",
        "optical":        "Santé",
        "opticien":       "Santé",

        // Maison / Bricolage
        "leroy merlin":   "Maison",
        "bricorama":      "Maison",
        "mr bricolage":   "Maison",
        "ikea":           "Maison",
        "but":            "Maison",
        "conforama":      "Maison",

        // Vêtements
        "zara":           "Vêtements",
        "h&m":            "Vêtements",
        "uniqlo":         "Vêtements",
        "kiabi":          "Vêtements",
        "celio":          "Vêtements",
        "jules":          "Vêtements",

        // Carburant
        "totalenergies":  "Carburant",
        "bp":             "Carburant",
        "shell":          "Carburant",
        "esso":           "Carburant",

        // Transport
        "sncf":           "Transport",
        "ratp":           "Transport",
        "ouigo":          "Transport",
        "uber":           "Transport",
        "blablacar":      "Transport",

        // Culture / High-Tech
        "fnac":           "Culture",
        "cultura":        "Culture",
        "darty":          "High-Tech",
        "boulanger":      "High-Tech",

        // Beauté
        "sephora":        "Beauté",
        "nocibe":         "Beauté",
        "yves rocher":    "Beauté",

        // Abonnements
        "netflix":        "Abonnement",
        "spotify":        "Abonnement",
        "amazon":         "Abonnement",
        "apple":          "Abonnement",
    ]
}
