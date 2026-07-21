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

## Risques restants (tracés dans ROADMAP)
- D1 (P1) scoring montant OCR · D2 (P2) annulation traitement OCR ·
  D3 (P3) tokens Typography Dynamic Type · D4 (P3) contraste cartes Dark ·
  D5 (P3 watch item) fragilité `.sheet`/`.fullScreenCover` (non reproductible).
- Hors scope : `fix(ticket-detail): dismiss after delete`.

## Recommandation
- **GO MERGE** — sous réserve du GO MERGE final du mainteneur.
