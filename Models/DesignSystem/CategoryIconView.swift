import SwiftUI

/// Icône de catégorie standardisée — round-square coloré, symbole blanc.
/// Style iOS des maquettes V2 (Support, Stats, Home, Bons).
struct CategoryIconView: View {

    let category: String
    var size: CGFloat = 40

    var body: some View {
        let style = CategoryStyle.style(for: category)
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                .fill(style.color)
            Image(systemName: style.icon)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
    }
}

#Preview("Système + custom") {
    VStack(spacing: 16) {
        HStack(spacing: 12) {
            CategoryIconView(category: "Alimentation")
            CategoryIconView(category: "Restaurant")
            CategoryIconView(category: "Transport")
            CategoryIconView(category: "Santé")
        }
        HStack(spacing: 12) {
            CategoryIconView(category: "Maison")
            CategoryIconView(category: "High-Tech")
            CategoryIconView(category: "Ma catégorie custom")
            CategoryIconView(category: "")
        }
        CategoryIconView(category: "Loisirs", size: 56)
    }
    .padding()
    .background(Theme.Background.primary)
}
