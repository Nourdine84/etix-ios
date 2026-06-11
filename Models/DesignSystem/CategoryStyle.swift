import SwiftUI

/// Mapping centralisé catégorie → (icône SF Symbol, couleur).
/// Couvre les 12 catégories système de CategoryPickerSheet, avec un fallback
/// déterministe pour les catégories custom : la couleur est dérivée d'un hash
/// stable du nom (PAS `hashValue`, dont la seed change à chaque lancement),
/// pour qu'une même catégorie garde la même couleur partout et pour toujours.
struct CategoryStyle {

    let icon: String
    let color: Color

    // MARK: - Catégories système

    private static let system: [String: CategoryStyle] = [
        "alimentation": CategoryStyle(icon: "cart.fill", color: .blue),
        "restaurant":   CategoryStyle(icon: "fork.knife", color: .orange),
        "transport":    CategoryStyle(icon: "bus.fill", color: .teal),
        "santé":        CategoryStyle(icon: "cross.case.fill", color: .red),
        "sport":        CategoryStyle(icon: "figure.run", color: .green),
        "maison":       CategoryStyle(icon: "house.fill", color: .yellow),
        "vêtements":    CategoryStyle(icon: "tshirt.fill", color: .purple),
        "culture":      CategoryStyle(icon: "book.fill", color: .indigo),
        "high-tech":    CategoryStyle(icon: "desktopcomputer", color: .cyan),
        "beauté":       CategoryStyle(icon: "sparkles", color: .pink),
        "carburant":    CategoryStyle(icon: "fuelpump.fill", color: .brown),
        "abonnement":   CategoryStyle(icon: "arrow.triangle.2.circlepath", color: .mint)
    ]

    /// Palette de fallback pour les catégories custom.
    private static let fallbackPalette: [Color] = [
        .blue, .green, .orange, .purple, .pink, .teal, .indigo, .mint
    ]

    // MARK: - API

    static func style(for category: String) -> CategoryStyle {
        let trimmed = category.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            return CategoryStyle(icon: "questionmark", color: .gray)
        }
        if let known = system[trimmed.lowercased()] {
            return known
        }
        let index = stableHash(trimmed.lowercased()) % fallbackPalette.count
        return CategoryStyle(icon: "tag.fill", color: fallbackPalette[index])
    }

    /// FNV-1a 32 bits — stable entre lancements et entre appareils.
    private static func stableHash(_ value: String) -> Int {
        var hash: UInt32 = 2_166_136_261
        for byte in value.utf8 {
            hash ^= UInt32(byte)
            hash = hash &* 16_777_619
        }
        return Int(hash % UInt32(Int32.max))
    }
}
