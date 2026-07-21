# ADR-0002 — Design System V2

## Contexte
Les écrans V1 étaient hétérogènes : styles codés à la main, valeurs dupliquées,
aucune cohérence de tokens ni de composants.

## Décision
Mise en place d'un Design System V2, adopté **écran par écran** (aucune migration de masse) :

- **Tokens `Theme`** : `Background`, `Radius`, `Spacing`, `Typography`, `Shadow`,
  définis en code (couleurs dynamiques via `UIColor`) — compatibles app **et** widget.
- **Composants** : `EtixBadge`, `PrimaryButton`, `CardContainer` (`.card()`),
  `SectionLabel`, `StatBlock`, `ProgressCapsule`, `CategoryIconView`, `AmbientBackground`.
- Règle : **ne pas créer de composant sans au moins deux consommateurs probables**.

## Alternatives rejetées
- Continuer le style ad hoc par écran (dette croissante, incohérence visuelle).

## Conséquences
- Cohérence visuelle croissante à mesure des redesigns (Splash, Onboarding, Home V3, AddTicket/Scanner).
- `eTixButton` déprécié puis **supprimé** une fois son dernier consommateur migré (Scanner V2).
- Dette connue (D3, P3) : les tokens `Typography` sont en **taille fixe** → ne respectent pas
  Dynamic Type de façon systémique ; les écrans neufs utilisent des styles sémantiques scalables
  en attendant une migration des tokens.
