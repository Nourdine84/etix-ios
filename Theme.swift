import SwiftUI

/// Design System eTix V2 — tokens dérivés des maquettes validées
/// (eTix_V2_Maquettes_Completes_Validees_FINAL).
///
/// ⚠️ Ce fichier est compilé dans DEUX targets (app + eTixWidgetExtension).
/// Les couleurs sont définies en code (UIColor dynamique) et non dans
/// Assets.xcassets : un nom d'asset déclaré dans le catalogue de l'app
/// résoudrait nil dans le widget.
enum Theme {

    /// #007BFF — bleu primaire eTix, constant light/dark
    static let primaryBlue = Color(red: 0/255, green: 123/255, blue: 255/255)

    // MARK: - Background

    /// Fonds applicatifs V2.
    /// Light : lavande très léger / blanc — Dark : navy profond uniforme.
    /// Non adoptés par les écrans V1 tant que leur redesign n'est pas lancé.
    enum Background {

        /// Fond d'écran principal — #EEF2FF / #0A0E1A
        static let primary = Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 10/255, green: 14/255, blue: 26/255, alpha: 1)
                : UIColor(red: 238/255, green: 242/255, blue: 255/255, alpha: 1)
        })

        /// Surface de carte — #FFFFFF / #141832
        static let surface = Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 20/255, green: 24/255, blue: 50/255, alpha: 1)
                : UIColor.white
        })

        /// Surface élevée (sheet, popup) — #FFFFFF / #1C2340
        static let elevated = Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 28/255, green: 35/255, blue: 64/255, alpha: 1)
                : UIColor.white
        })
    }

    // MARK: - Radius

    enum Radius {
        /// Tags, badges, chips
        static let s: CGFloat = 8
        /// Champs de saisie, rangées
        static let m: CGFloat = 12
        /// Boutons CTA (valeur maquette, déjà utilisée 3× dans le code V1)
        static let button: CGFloat = 14
        /// Cartes standard
        static let l: CGFloat = 16
        /// Grandes cartes, bottom sheets
        static let xl: CGFloat = 20
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
        static let xl: CGFloat = 20
        /// Inset horizontal d'écran
        static let xxl: CGFloat = 24
        /// Entre sections d'un écran
        static let section: CGFloat = 32
    }

    // MARK: - Typography

    /// Tokens Font purs. Le tracking et l'uppercase de l'overline ne sont pas
    /// des propriétés de Font — ils vivent dans le composant SectionLabel.
    enum Typography {
        /// Montants principaux (Home, Store hero)
        static let displayAmount = Font.system(size: 40, weight: .heavy, design: .rounded)
        /// Titres d'écran
        static let screenTitle = Font.system(size: 22, weight: .semibold)
        /// Titres de carte / section
        static let headline = Font.system(size: 17, weight: .semibold)
        /// Texte courant
        static let body = Font.system(size: 16, weight: .regular)
        /// Lignes secondaires
        static let subheadline = Font.system(size: 15, weight: .regular)
        /// Métadonnées
        static let caption = Font.system(size: 13, weight: .regular)
        /// Labels de section uppercase (voir SectionLabel)
        static let overline = Font.system(size: 11, weight: .medium)
    }

    // MARK: - Shadow

    /// Ombre de carte — appliquée en light uniquement (invisible sur navy).
    enum Shadow {
        static let cardColor = Color.black.opacity(0.06)
        static let cardRadius: CGFloat = 12
        static let cardY: CGFloat = 4
    }
}
