# ADR-0003 — Home Architecture

## Contexte
La Home V1 recalculait ses agrégats plusieurs fois par render (jusqu'à ~8 reconstructions
d'un snapshot + une génération KPI legacy en parallèle), avec des données dérivées dupliquées.

## Décision
La Home dérive d'un **unique `HomeSnapshot`** construit **une seule fois par render**
(un seul passage O(N) sur les tickets), source de tous les agrégats. Suppression de la
couche KPI legacy parallèle.

Règle d'affichage : **une seule carte contextuelle** à la fois, résolue de façon
**déterministe** (Budget ⊻ Store) ; maximum 2 insights ; `budgetExceeded` prioritaire.

## Alternatives rejetées
- ViewModel dédié (sur-architecture vs la réactivité déjà fournie par `@FetchRequest`).
- Cache dérivé en `@State` (risque de staleness / donnée incohérente).

## Conséquences
- Un seul passage O(N) par recalcul utile ; réactivité immédiate après ajout/édition/suppression ;
  aucune donnée dérivée stockée.
- Décision d'**architecture durable** : reste pertinente même si l'implémentation de Home évolue
  (V4/V5). C'est le **modèle de données** (`HomeSnapshot` unique) qui est acté, pas un écran.
- Dette connue (D4, P3) : contraste des cartes teintées en Dark Mode à revoir.
