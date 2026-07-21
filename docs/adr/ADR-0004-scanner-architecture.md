# ADR-0004 — Scanner Architecture

## Contexte
L'application doit scanner des tickets. La maquette V2 suggère un scanner « custom »
(cadre, aperçu). Or iOS fournit `VNDocumentCameraViewController` (détection de bords,
correction de perspective, deskew, multipage) d'excellente qualité.

## Décision
**Option C — Hybride** : conserver `VNDocumentCameraViewController` pour la **capture**,
et **premiumiser uniquement l'expérience autour** (intro, priming caméra, traitement,
repli, succès) avec le Design System V2.

Le flux est piloté par une **source de vérité unique** — `ScannerFlowView` avec
`enum ScannerStep { intro, priming, camera, processing, notFound }` — présentée dans
**une seule** modale (`fullScreenCover` d'`AddTicketView`). Aucune cover imbriquée.
Pipeline stratifié : capture (`OCRScannerView`, événementiel) → reconnaissance
(`TextRecognizer`, hors main-thread) → parsing (`ReceiptParser`) → modèle métier.

## Alternatives rejetées
- **Scanner AVFoundation + Vision entièrement custom** : coût élevé, maintenance lourde,
  risque réel de **dégrader** la qualité de détection d'Apple, HIG à re-gagner.

## Pourquoi
Fiabilité, maintenance quasi nulle, qualité OCR supérieure, conformité HIG.

## Conséquences
- Scanner Apple conservé (capture non stylable) ; design personnalisé **avant et après** la capture.
- Le cadre de l'intro est une **illustration statique** (ticket + coins d'accroche),
  **pas** un aperçu caméra live.
- **Décision UX (P1)** : après enregistrement d'un ticket → *popup de succès + formulaire
  réinitialisé, l'utilisateur reste sur AddTicket*. Le **retour automatique vers Home** est
  **volontairement différé au Sprint 6 (Navigation)**. Ce n'est **pas un défaut**.
- Reconnaissance déplacée hors du main-thread → plus de gel pendant l'OCR.

## Limites connues
- **Propagation du thème (D6, P3)** : les écrans du flux scanner sont présentés
  dans un `fullScreenCover`, qui **n'hérite pas** du `.preferredColorScheme` de la
  racine. Ils suivent donc le **thème système**, pas le choix de thème eTix.
  Fonctionnel en Light/Dark système ; incohérence visuelle uniquement. Différé — voir ROADMAP.
- Autres dettes associées : D1 (scoring montant, P1), D2 (annulation traitement, P2),
  D5 (fragilité `.sheet`/`.fullScreenCover`, P3 watch item non reproductible) — voir ROADMAP.
