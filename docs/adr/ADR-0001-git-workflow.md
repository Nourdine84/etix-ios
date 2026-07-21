# ADR-0001 — Git Workflow

## Contexte
Projet mono-développeur mais destiné à durer jusqu'à la release et au-delà.
Besoin d'un historique lisible et de merges tracés.

## Décision
Adoption d'un Git Flow :

```
main  ←  release/x.y  ←  develop  ←  feature|fix|refactor/*
```

- `main` : versions stables uniquement.
- `develop` : branche de référence, intégration des features validées.
- `feature/*`, `fix/*`, `refactor/*` : une évolution par branche, **partant toujours de `develop`**.
- **Conventional Commits** obligatoires ; les messages décrivent la fonctionnalité, jamais l'outil.
- **Aucun développement direct sur `develop`** : elle ne reçoit que des merges validés (`--no-ff`).
- **Fiche de clôture obligatoire** avant chaque merge (voir DoD).
- Identité Git du dépôt : `Nourdine84 <tn.smok@hotmail.fr>`.

## Alternatives rejetées
- Commits directs sur une branche unique (pas de traçabilité, pas de point de stabilité).

## Conséquences
- `develop` a été créée sur `33d74cd` (état intégré **avant** le sprint Scanner V2),
  et non sur une feature en cours — pour éviter d'y intégrer du travail non terminé.
- Chaque feature apporte **son code ET sa documentation** (fiche de clôture, ADR, roadmap) à son merge.
- La gouvernance est gelée : on applique les règles plutôt que d'en créer de nouvelles.
