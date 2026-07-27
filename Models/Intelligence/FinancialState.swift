import Foundation

/// État financier synthétique et **global** de l'utilisateur — **agnostique de
/// la surface** (Home, Widget, Notifications, Apple Watch, Dashboard).
///
/// Il n'expose qu'un **état sémantique** (`kind`) + un **ton** : jamais de
/// catégorie, de magasin, d'action, ni de texte. La copie éditoriale vit dans
/// chaque surface (ex. `HomeFinancialCopy` côté Home).
enum FinancialStateKind: Equatable {
    case welcome        // aucune donnée
    case building       // suivi débutant (données insuffisantes)
    case saving         // dépenses nettement en baisse
    case underControl   // maîtrisé
    case steady         // stable, rien de notable
    case slightRise     // légère hausse
    case highSpending   // rythme élevé
}

enum FinancialTone: Equatable {
    case positive
    case neutral
    case attention
}

struct FinancialState: Equatable {
    let kind: FinancialStateKind
    let tone: FinancialTone
}
