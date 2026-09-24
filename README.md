# Mekano Afrika

Application mobile de mise en relation entre acheteurs et vendeurs de matériel
informatique et électronique à Abidjan. Le catalogue est classé par proximité,
le prix se négocie dans l'application, et un vendeur informel y travaille sans
avoir à justifier d'un statut.

Projet réalisé par **GNAZOU Bernard** dans le cadre de la formation D-CLIC,
niveau III (Flutter / Dart). Le rapport d'activité qui accompagne ce dépôt se
trouve à la racine : `Rapport_Projet_Mekano_Afrika_GNAZOU_BERNARD.docx`.

---

## Le problème auquel l'application répond

À Abidjan, l'essentiel du commerce de matériel informatique se fait de la main
à la main : une boutique d'Adjamé, un réparateur de quartier, un revendeur qui
n'a ni vitrine ni registre de commerce. Les places de marché existantes
supposent l'inverse — un vendeur enregistré, un prix fixe, un paiement en
ligne, une connexion stable.

Trois contraintes ont donc structuré tout le projet, et se retrouvent dans
presque chaque décision technique décrite plus bas :

1. **Le statut informel ne doit rien bloquer.** Un vendeur se déclare, aucune
   pièce n'est demandée, et ce statut n'ouvre ni ne ferme aucune fonction.
2. **La proximité est le moteur de la découverte**, pas un filtre secondaire.
   Mais un refus de géolocalisation ne doit jamais interrompre le parcours.
3. **Le réseau est instable.** L'application doit rester utilisable, et surtout
   démontrable, quand la base est injoignable.

## Ce que l'application fait

- **Découverte par proximité.** L'accueil ordonne annonces et boutiques selon
  la distance à la position de l'utilisateur, calculée par la formule de
  Haversine (`lib/utils/distance.dart`). Si le GPS est refusé ou indisponible,
  l'utilisateur choisit sa commune dans une liste et tout le reste fonctionne
  à l'identique.
- **Recherche et filtres** combinables : catégorie, fourchette de prix,
  distance maximale, état du produit, forme d'échange, annonces au tarif de
  gros uniquement. Tri par pertinence, par prix ou par proximité. Le filtrage
  s'exécute sur l'appareil, sans aller-retour réseau.
- **Négociation du prix.** Une offre est un message typé, porteur de son propre
  statut, ce qui permet de suivre une négociation indépendamment du fil de
  discussion. Le temps réel passe par les flux `snapshots()` de Firestore.
- **Panier à double tarif.** Chaque ligne est revalorisée à chaque changement
  de quantité : franchir le seuil de gros d'un produit fait basculer la ligne
  au tarif de gros, et redescendre en dessous rétablit le tarif de détail.
  Livraison forfaitaire de 5 000 FCFA, offerte à partir de 100 000 FCFA.
- **Favoris, compte et bascule vendeur.** On passe d'acheteur à vendeur sans
  créer de second compte.

Les captures du parcours complet sont dans `captures/` (les fichiers préfixés
`refonte-` correspondent à la seconde version de l'interface).

## Décisions techniques, et pourquoi

Les choix ci-dessous sont ceux sur lesquels je suis revenu en cours de route,
ou qui s'écartent du dossier de conception initial. Ils sont documentés dans le
code, à l'endroit où ils s'appliquent.

**Architecture MVC avec une couche de dépôts.** Les vues n'appellent jamais la
base. Un contrôleur ne va pas chercher sa source de données non plus : il la
reçoit à la construction, dans `main.dart`. C'est ce qui permet de lui confier
un dépôt de remplacement en test sans toucher à sa logique — les tests de
`test/depots_test.dart` reposent entièrement là-dessus.

**Firestore plutôt que Socket.io pour le temps réel.** Le dossier de conception
prévoyait Socket.io. Firestore ayant été retenu comme base, ses flux
`snapshots()` assurent déjà la diffusion des écritures aux participants
connectés ; ajouter un second canal aurait doublé l'infrastructure sans rien
apporter au modèle. L'écart est assumé et justifié au rapport.

**Repli automatique en mode démonstration.** Si Firebase n'est pas joignable —
configuration absente, plateforme non déclarée, réseau coupé — l'application
démarre quand même sur le jeu de données local (`lib/donnees/jeu_demonstration.dart`)
et le signale à l'écran de compte. Une soutenance ne doit pas dépendre de la
disponibilité d'un service distant.

**Écriture optimiste sur les favoris et le panier.** L'état change à l'écran
d'abord, l'écriture distante suit. Attendre la confirmation du serveur pour
cocher un cœur rend la carte produit poussive dès que le réseau faiblit.

**Police d'icônes réduite.** Les `Icons` du SDK datent de 2018. L'application
embarque les Material Symbols Rounded, réduits aux seuls glyphes réellement
appelés dans `lib/` par `tool/preparer_symboles.py`.

**Images redimensionnées à leur taille d'affichage.** Les visuels livrés
montaient à 2 560 pixels de côté pour un affichage qui n'en demande jamais plus
de trois cents. Au-delà du poids du paquet, c'est la mémoire vive qui posait
problème : Flutter décompresse chaque image affichée.

## Organisation du code

```
lib/
├── main.dart          Démarrage, injection des dépôts dans les contrôleurs
├── models/            Produit, Boutique, Utilisateur, Conversation, Avis…
│                      Les règles de prix sont portées ici, pas dans les vues
├── views/             Un fichier par écran (14 fichiers)
├── controllers/       État applicatif, exposé par ChangeNotifier
├── data/              Dépôts : seule couche qui connaît Firestore
├── services/          Accès Firebase, géolocalisation
├── donnees/           Jeu de démonstration, communes d'Abidjan
├── theme/             Couleurs, typographie, dimensions, formes, symboles
├── widgets/
│   ├── communs/       Boutons, champs, états vides, logo, fonds
│   └── metier/        Cartes produit, indicateurs, panneau de négociation
└── utils/             Distance, formats (prix, notes, compteurs)
```

`lib/views/galerie_composants.dart` rassemble tous les composants de la
bibliothèque sur un seul écran : c'est l'écran qui m'a servi à vérifier la
cohérence visuelle après chaque modification du thème.

## Tests

76 tests, lancés par `flutter test` :

| Fichier | Couvre |
|---|---|
| `regles_metier_test.dart` | Bascule au tarif de gros, livraison, codes promo |
| `panier_test.dart` | Contenu du panier, cumul des quantités, retrait de ligne |
| `distance_test.dart` | Haversine et mise en forme des distances |
| `formats_test.dart` | Prix, notes, compteurs abrégés, espace insécable |
| `depots_test.dart` | Repli sur le jeu local quand la base est vide ou muette |
| `ressources_test.dart` | Chaque image citée existe, est déclarée, n'est pas démesurée |
| `debordements_test.dart` | Écrans passés au crible du dépassement de mise en page |

`ressources_test.dart` a attrapé plusieurs images absentes du manifeste :
déclarer un dossier dans `pubspec.yaml` ne couvre pas ses sous-dossiers, et
l'oubli ne produit aucune erreur à la compilation — l'image reste simplement
vide à l'exécution.

## Outils

Scripts Python à la racine de `tool/`, à lancer depuis le dossier du projet :

| Script | Rôle |
|---|---|
| `preparer_symboles.py` | Recense les icônes utilisées et réduit la police à ces glyphes |
| `preparer_logo.py` | Recentre le logo et en tire ses déclinaisons (monogramme, fond sombre) |
| `optimiser_images.py` | Ramène les visuels à leur taille d'affichage réelle |
| `rapport_docx.py` | Engendre le rapport d'activité sur le gabarit D-CLIC |
| `contenu_rapport.py` | Texte du rapport, séparé de sa mise en forme |

## Installation

Prérequis : Flutter avec Dart SDK 3.10.4 ou supérieur.

```bash
flutter pub get
flutter run
```

L'application démarre en mode démonstration sans configuration
supplémentaire. Pour la brancher sur Firebase, placer `google-services.json`
dans `android/app/` — le projet Firebase associé est `mekano-afrika`. Une base
vide se garnit depuis l'écran de compte, qui écrit le jeu de démonstration
dans Firestore sans passer par la console.

## Limites connues

- Les codes promotionnels sont vérifiés sur l'appareil. Une remise réelle
  devra être validée par le serveur : un contrôle côté client se contourne.
- Les frais de livraison sont forfaitaires, à l'échelle d'une course entre deux
  communes d'Abidjan. La livraison longue distance relève d'une version
  ultérieure.
- Le paiement n'est pas implémenté : la transaction se conclut hors
  application, ce qui correspond à l'usage visé pour cette première version.
- Les règles de sécurité Firestore sont en mode test et expirent en octobre
  2026 ; elles sont à durcir avant tout usage réel.

## Crédits

Police Inter et Material Symbols Rounded sous licence SIL Open Font
(`assets/fonts/OFL.txt`). Fond cartographique OpenStreetMap via `flutter_map`.
Les logos de boutiques et photographies de produits servent uniquement à la
démonstration.
