# Fiche de clôture — feature/scanner-v2

## Objectifs atteints
- ✅ `ReceiptParser` pur et testable ; modèle de confiance OCR en paliers (`OCRConfidence`).
- ✅ Validation du montant à virgule (`AmountParser`, partagé Add + Edit).
- ✅ `TicketForm` partagé Add + Edit (Design System V2) + badges de confiance OCR.
- ✅ Écran d'intro Scanner premium + **point d'entrée unifié** (Home + AddTicket).
- ✅ Priming caméra premium + permission centralisée (conforme maquette).
- ✅ OCR **hors main-thread** (`TextRecognizer`) + écran de traitement + repli « rien détecté ».
- ✅ **Flatten presentation** : une seule modale, flux piloté par `ScannerStep`, plus de covers imbriquées.
- ✅ Suppression de `eTixButton`, `CameraPermission`, `OCRNotifications` (dette fermée).
- ✅ Correctif gel popup (`PopupContainer`, anti-pattern `value: UUID()`).
- ✅ **BUG 4** corrigé : plus de nom de magasin fantôme sur OCR vide → l'écran « Aucune information détectée » est de nouveau atteignable.
- ✅ **BUG 3** corrigé : permission caméra refusée → alerte explicite + accès aux Réglages + état stable.

## Architecture
- **ADR-0004** — Option C : `VNDocumentCameraViewController` conservé, premiumisation autour.
- Pipeline : `OCRScannerView` (capture, événementiel) → `TextRecognizer` (Vision, off-main)
  → `ReceiptParser` (parsing) → `OCRExtractedData`.
- Source de vérité unique : `ScannerFlowView` + `enum ScannerStep`.

## Décision UX (P1)
- Après enregistrement : *popup + formulaire réinitialisé, l'utilisateur reste sur AddTicket*.
- Le **retour Home** est **différé au Sprint 6 (Navigation)** — **pas un bug** (voir ADR-0004 / ROADMAP).

## Fichiers créés
- `Models/OCR/ReceiptParser.swift`, `Models/OCR/TextRecognizer.swift`
- `Models/Utils/AmountParser.swift`
- `Models/Views/Tickets/TicketForm.swift`
- `Models/Views/OCR/ScannerFlowView.swift`, `CameraPrimingView.swift`, `OCRProcessingView.swift`

## Fichiers supprimés (dette fermée)
- `Models/Utils/UIComponents/eTixButton.swift`
- `Models/Views/OCR/CameraPermission.swift`
- `Models/Utils/OCRNotifications.swift`

## Fichiers modifiés
- `OCRExtractedData.swift`, `OCRScannerView.swift`, `AddTicketView.swift`,
  `TicketEditView.swift`, `AddTicketViewModel.swift`, `PopupContainer.swift`,
  `project.pbxproj`, `eTixTests.swift`

## Breaking changes
- Aucun.

## Build
- ✅ Validé par le mainteneur à chaque étape (⌘B), y compris après le flatten et le fix popup.

## Tests
- ✅ `ReceiptParserTests`, `AmountParserTests`, `FieldConfidenceMappingTests`,
  `OCRExtractedDataTests` (Swift Testing).

## Validations réalisées (recette)
- Flatten : Q2, Q5, Q19, Q20 — PASS ; Q1 — voir ci-dessous.
- Popup : gel supprimé (P2/P3/P6 PASS) ; P1 reclassé **conforme** (décision UX) ;
  P4/P5 = bug **hors périmètre** (`fix(ticket-detail): dismiss after delete`).
- **Q1** : classé **NON REPRODUCTIBLE** depuis un lancement propre (comportement correct dès le 1ᵉʳ appui).
  Aucun correctif appliqué (pas de scénario de reproduction fiable). Fragilité latente tracée en D5 (P3 watch item).
- **BUG 4** : ticket exploitable → magasin correct ; texte sans magasin identifiable → aucun nom fantôme ;
  feuille blanche / OCR vide → « Aucune information détectée » ; saisie manuelle disponible ; montant/date non régressés.
- **BUG 3** : accordée → caméra ; 1ᵉʳ refus → alerte ; déjà refusée → alerte + Réglages ; annulation → état stable ;
  retour depuis Réglages après autorisation → scanner utilisable ; aucun empilement `.sheet`/`.alert`/`.fullScreenCover`.

## DoD Scanner V2 (complétée)

| Critère | Statut |
|---|---|
| Build Xcode vert | ✅ validé par le mainteneur (à chaque étape ; commits doc/fix depuis) |
| Aucun warning bloquant | ✅ aucun signalé |
| Tests unitaires adaptés | ✅ ReceiptParser / AmountParser / FieldConfidence / OCRExtractedData |
| Feature validée fonctionnellement | ✅ recette flatten + popup + BUG 3/BUG 4 |
| Light Mode | ✅ système |
| Dark Mode | ⚠️ **fonctionnel en thème système** ; propagation du thème eTix différée → **D6 (P3)** |
| iPhone SE | ✅ |
| iPhone Pro Max | ✅ |
| Dynamic Type | ✅ (styles sémantiques, étape 5.1) |
| Aucun code mort | ✅ (eTixButton / CameraPermission / OCRNotifications supprimés) |
| Aucune duplication inutile | ✅ (TicketForm partagé, parsing extrait) |
| Respect du Design System | ✅ |
| Pas de régression connue | ✅ |
| Conventional Commits | ✅ |
| Branche conforme Git Flow | ✅ `feature/scanner-v2` ← `develop` |
| Historique propre | ✅ |
| Fiche de clôture | ✅ (ce document) |
| ADR ajouté | ✅ ADR-0004 |
| Roadmap à jour | ✅ (D1..D6 + ticket hors scope) |
| Dette corrigée OU tracée | ✅ (D1..D6 tracées ; BUG 3/BUG 4 corrigés) |
| GO MERGE validé | ⏸️ en attente du mainteneur |

**Aucun critère laissé ouvert sans justification** : le seul point non pleinement vert (thème Dark) est **tracé comme dette D6 (P3), non bloquant**.

## Risques restants (tracés dans ROADMAP)
- D1 (P1) scoring montant OCR · D2 (P2) annulation traitement OCR ·
  D3 (P3) tokens Typography Dynamic Type · D4 (P3) contraste cartes Dark ·
  D5 (P3 watch item) fragilité `.sheet`/`.fullScreenCover` (non reproductible) ·
  **D6 (P3) propagation du thème eTix au flux scanner**.
- Hors scope : `fix(ticket-detail): dismiss after delete`.

## Recommandation
- **GO MERGE** — sous réserve du GO MERGE final du mainteneur.
