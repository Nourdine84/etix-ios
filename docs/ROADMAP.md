# ROADMAP technique — eTix

## Sprints produit
- Sprint 1 — ✅ Home V3
- Sprint 2 — ✅ Scanner V2 *(en clôture)*
- Sprint 3 — ⏳ History V2
- Sprint 4 — ⏳ Store V2
- Sprint 5 — ⏳ Budget V2
- Sprint 6 — ⏳ Navigation / TabBar V2
- Sprint 7 — ⏳ Stabilisation & TestFlight
- Sprint 8 — ⏳ Release 2.0

## Décisions produit à honorer
- **Retour Home après enregistrement d'un ticket** : volontairement **différé au Sprint 6 (Navigation)**.
  Comportement actuel assumé : *Enregistrer → popup → formulaire réinitialisé → rester sur AddTicket*.
  Ce n'est **pas** un bug (voir ADR-0004).

## Dette technique tracée
| ID | Priorité | Sujet | Périmètre |
|----|----------|-------|-----------|
| D1 | **P1** | ReceiptParser — désambiguïsation du montant par **scoring** (TOTAL TTC vs HT/TVA/sous-total/remise) + cohérence `HT + TVA = TTC` + confiance abaissée en cas d'ambiguïté | `ReceiptParser` + tests |
| D2 | **P2** | Annulation du traitement OCR pendant `OCRProcessingView` — à réévaluer selon la durée réelle du traitement sur appareil | `OCRProcessingView` + `ScannerFlowView` |
| D3 | **P3** | Tokens `Theme.Typography` en taille fixe → migrer vers des styles sémantiques scalables (Dynamic Type systémique) | Design System (transverse) |
| D4 | **P3** | Contraste des cartes Insight/Budget/Store en Dark Mode (hérité Home A2) | Écrans Home / cartes |
| D5 | **P3 — watch item** | **Fragilité SwiftUI potentielle, non confirmée** : co-location `.fullScreenCover` + `.sheet` sur `AddTicketView`. **Non reproductible** dans le code actuel (Q1 classé NON REPRODUCTIBLE). Aucune action tant qu'aucun cas reproductible n'est constaté. **Non bloquant, pas un bug ouvert.** | `AddTicketView` |
| D6 | **P3** | **Scanner V2 : propager le thème eTix au flux scanner** afin que les écrans utilisent le choix de thème de l'application (`AppAppearance`) et non uniquement le thème système. Cause : un `fullScreenCover` n'hérite pas du `.preferredColorScheme` de la racine. Fonctionnel en Light/Dark système, incohérence visuelle uniquement. **Non bloquant.** | `ScannerFlowView` / `AddTicketView` (contenu du cover) |

## Bugs hors périmètre (tickets dédiés)
| Ticket | Sujet | Périmètre |
|--------|-------|-----------|
| `fix(ticket-detail): dismiss after delete` | Après confirmation de suppression, la vue détail ne se referme pas (le `dismiss()` est codé mais inopérant). Indépendant du scanner. | `TicketDetailView` |
