#!/usr/bin/env python3
"""Contenu rédactionnel du rapport d'activité.

Séparé de `rapport_docx.py`, qui n'a la charge que de la mise en forme : le
texte se relit et se corrige ici sans toucher au gabarit.
"""

from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.shared import Cm


def objectifs(document, ligne, titre, puces, capture):
    """Page des objectifs, telle que la prévoit le gabarit."""
    ligne(
        document,
        "OBJECTIFS CLES DE L'ACTIVITE :",
        taille=14,
        gras=True,
        espace_apres=14,
    )

    puces(document, [
        "Concevoir et réaliser une application mobile complète avec Flutter, "
        "de la maquette à l'application installée sur un téléphone.",
        "Structurer un projet Dart en couches distinctes, modèles, "
        "contrôleurs, services, vues, pour qu'il reste modifiable.",
        "Mettre en œuvre un système de design cohérent : palette, "
        "typographie, formes, profondeur et mouvement.",
        "Gérer l'état de l'application avec Provider, et son alimentation par "
        "Cloud Firestore avec repli hors connexion.",
        "Traduire des règles de gestion en code vérifié par des tests "
        "automatisés.",
        "Exploiter la géolocalisation pour classer une offre par proximité.",
        "Tenir les contraintes d'un terrain réel : téléphones d'entrée de "
        "gamme, réseau instable, lecture en plein soleil.",
        "Documenter le projet pour qu'un lecteur extérieur puisse le "
        "reprendre : rôle de chaque couche, décisions techniques et leurs "
        "raisons, marche à suivre pour l'installer.",
        "Vérifier le résultat par une campagne de tests automatisés, et "
        "préparer la démonstration de l'application sur appareil réel.",
        "Placer le projet sous gestion de version et constituer l'espace de "
        "dépôt attendu à la remise.",
    ])

    ligne(document, espace_apres=10)
    capture(
        document,
        "v2-09-accueil.png",
        "Écran d'accueil de l'application Mekano Afrika",
        largeur=Cm(7.6),
    )


def corps(document, ligne, titre, puces, tableau, capture):
    """Synthèse et développements."""

    # ------------------------------------------------------------------
    ligne(document, "SYNTHESE :", taille=14, gras=True, espace_apres=12)

    ligne(document,
        "À travers la réalisation de ce projet final, j'ai conçu et développé "
        "« Mekano Afrika », une application mobile de place de marché dédiée "
        "au matériel technologique en Afrique de l'Ouest. Le projet part d'un "
        "constat simple : le commerce technologique africain reste largement "
        "informel et géographiquement fragmenté. Un acheteur ignore ce qui se "
        "vend à deux kilomètres de chez lui, et un vendeur de quartier n'a "
        "aucun moyen d'être visible au-delà de sa rue.",
        espace_apres=10)

    ligne(document,
        "L'application répond à ce problème en plaçant la proximité au centre "
        "du parcours : chaque annonce affiche sa distance, les résultats sont "
        "classés du plus proche au plus lointain, et la négociation, pratique "
        "culturelle du marché africain, se fait directement dans "
        "l'application plutôt que par un canal extérieur.",
        espace_apres=10)

    ligne(document,
        "Le travail s'est déroulé en trois temps : la conception, appuyée sur "
        "le cahier des charges et le dossier de conception déjà rendus ; le "
        "développement de l'application Flutter ; puis une refonte complète de "
        "l'interface, menée jusqu'à la vérification sur appareil. Ce dernier "
        "temps est celui qui m'a le plus appris, et c'est sur lui que "
        "s'attarde ce rapport.",
        espace_apres=10)

    # ------------------------------------------------------------------
    titre(document, "1. Présentation du projet")

    ligne(document,
        "Mekano Afrika réunit sur un même espace des boutiques enregistrées et "
        "des vendeurs de quartier. Le statut informel d'un vendeur ne "
        "conditionne aucun accès : aucun document n'est exigé pour publier une "
        "annonce, ce qui constitue l'exigence la plus structurante du cahier "
        "des charges.",
        espace_apres=10)

    ligne(document, "Fonctions couvertes par la version réalisée :",
          gras=True, espace_apres=6)
    puces(document, [
        ("Découverte par proximité", ", annonces et boutiques classées selon "
         "la distance réelle, calculée sur l'appareil."),
        ("Recherche et filtres", ", par catégorie, prix, distance et état du "
         "produit ; bascule entre annonces et boutiques."),
        ("Fiche produit", ", galerie, caractéristiques, tarif de détail et "
         "tarif de gros, ajout au panier."),
        ("Négociation", ", discussion avec le vendeur, proposition de prix, "
         "contre-offre, acceptation ou refus."),
        ("Panier et commande", ", bascule automatique au tarif de gros, code "
         "promotionnel, frais de livraison."),
        ("Compte", ", profil, zone, favoris, commandes, activation de la "
         "vente sans justificatif."),
    ])

    # ------------------------------------------------------------------
    titre(document, "2. Architecture : le modèle MVC")

    ligne(document,
        "L'application applique le modèle MVC tel qu'il a été étudié au cours "
        "de la semaine 1. Le principe que ce modèle sert à faire respecter est "
        "simple à énoncer et difficile à tenir : ne jamais mêler, dans un même "
        "fichier, l'affichage, la logique métier et l'accès aux données.",
        espace_apres=10)

    tableau(document,
        ["Couche", "Rôle", "Contenu"],
        [
            ["models/", "Données et règles métier",
             "Produit, Boutique, Utilisateur, Message, Avis, Panier"],
            ["data/", "Accès aux données",
             "Cinq dépôts : utilisateurs, catalogue, panier, favoris, "
             "conversations"],
            ["controllers/", "Logique de contrôle et état",
             "Six contrôleurs, chacun un ChangeNotifier"],
            ["views/", "Écrans", "Quatorze écrans, du démarrage au compte"],
            ["widgets/", "Composants d'interface",
             "Communs et métier, réutilisables"],
            ["theme/", "Système de design",
             "Couleurs, typographie, formes, profondeur, mouvement, symboles"],
            ["services/", "Connexion aux services",
             "Démarrage de Firebase, géolocalisation"],
            ["donnees/", "Jeu de démonstration",
             "Catalogue local permettant de parcourir l'application sans "
             "réseau"],
        ])

    titre(document, "2.1 Le rôle de chaque couche", niveau=3)
    puces(document, [
        ("Le Model", " porte les données et les règles qui ne dépendent que "
         "d'elles : le prix appliqué à une quantité, le franchissement du "
         "palier de gros, le pourcentage de réduction, la distance entre deux "
         "points. Il ignore totalement Flutter."),
        ("La couche d'accès aux données", " est seule à connaître la base et "
         "ses requêtes. Un dépôt reçoit une demande et renvoie des objets du "
         "domaine ; il ne laisse jamais filtrer une collection, un document ni "
         "une exception propre au fournisseur."),
        ("Le Controller", " reçoit les actions de l'écran, appelle le dépôt, "
         "tient l'état, chargement, erreur, contenu, et prévient l'interface "
         "par notifyListeners(). C'est la forme que le cours retient pour "
         "Flutter."),
        ("La View", " affiche cet état et transmet les gestes de "
         "l'utilisateur. Elle ne calcule rien et n'accède à aucune donnée."),
    ])

    titre(document, "2.2 L'injection des dépôts", niveau=3)
    ligne(document,
        "Chaque contrôleur reçoit son dépôt à la construction, et non l'inverse "
        ": il ne va jamais chercher sa source de données. Les cinq dépôts sont "
        "créés une seule fois, au démarrage, puis confiés aux contrôleurs par "
        "Provider.",
        espace_apres=8)

    ligne(document,
        "Ce détail commande toute la testabilité du projet. Tant que les "
        "contrôleurs interrogeaient la base eux-mêmes, éprouver trois lignes "
        "de logique aurait exigé un émulateur Firestore, un réseau et un jeu "
        "de données distant. Depuis qu'ils reçoivent leur source, il suffit de "
        "leur en fournir une autre : sept vérifications portent désormais sur "
        "le chargement du catalogue et la gestion des favoris, dont le repli "
        "sur le jeu local lorsque la base est vide ou injoignable.",
        espace_apres=10)

    ligne(document,
        "L'état est porté par Provider, déclaré au-dessus de la navigation : "
        "la position choisie et la session survivent ainsi aux changements "
        "d'écran. Lorsque Firebase est indisponible, l'application bascule "
        "d'elle-même sur le jeu de données local au lieu d'interrompre le "
        "parcours, comportement indispensable pour une démonstration, et "
        "conforme au mode dégradé prévu au dossier de conception.",
        espace_apres=10)

    # ------------------------------------------------------------------
    titre(document, "3. Le système de design")

    ligne(document,
        "La charte impose une base noir, blanc et gris relevée d'un accent "
        "orange minimal. Trois règles gouvernent son emploi : l'orange signale "
        "ce qui porte de la valeur, prix, distance, note, état actif ; le "
        "noir est réservé à l'action qui engage ; le blanc n'est pas une "
        "couleur unique mais une pile de teintes très proches, qui crée la "
        "profondeur sans ombre appuyée.",
        espace_apres=10)

    titre(document, "3.1 L'élévation éclaircit", niveau=3)
    ligne(document,
        "Le premier état de l'interface souffrait d'un défaut que je n'avais "
        "pas vu avant de mesurer les couleurs à l'écran : le fond était blanc "
        "pur et les cartes légèrement plus sombres. Une carte paraissait donc "
        "enfoncée dans la page au lieu d'y être posée. Material 3 prescrit "
        "l'inverse : plus une surface s'élève, plus elle s'éclaircit. Le fond "
        "est descendu à un blanc très légèrement creusé et les cartes sont "
        "montées au blanc pur. C'est le seul changement qui a suffi à donner "
        "de la profondeur à tous les écrans.",
        espace_apres=10)

    titre(document, "3.2 Contraste et lisibilité", niveau=3)
    ligne(document,
        "En vérifiant les rapports de contraste, j'ai découvert que le gris "
        "employé pour les mentions et les textes de substitution plafonnait à "
        "2,4:1 sur le fond, là où la norme WCAG AA en exige 4,5. Sur un "
        "téléphone d'entrée de gamme lu en plein soleil, ce texte était "
        "illisible. Toute l'échelle d'encre a été décalée vers le sombre :",
        espace_apres=8)

    tableau(document,
        ["Rôle", "Couleur", "Contraste sur le fond", "Conformité"],
        [
            ["Texte principal", "#17171A", "17,5:1", "AA et AAA"],
            ["Texte secondaire", "#5C616A", "5,9:1", "AA"],
            ["Mentions, indications", "#70747B", "4,5:1", "AA"],
            ["Orange de marque", "#F26B0F", "3,1:1", "Aplats et grands corps"],
            ["Orange de texte", "#C4510A", "4,6:1", "AA"],
        ])

    ligne(document,
        "L'orange de la marque ne peut donc pas porter un libellé de petite "
        "taille sur fond clair : une déclinaison assombrie a été ajoutée pour "
        "cet usage, sans que la couleur de l'enseigne change.",
        espace_apres=10)

    titre(document, "3.3 Formes, profondeur et mouvement", niveau=3)
    puces(document, [
        ("Formes", ", toutes les surfaces sont découpées dans une "
         "superellipse arrondie, dite « squircle », dont le rayon varie de "
         "façon continue. Le coin paraît plus doux qu'un arrondi circulaire à "
         "rayon égal, et le rendu est assuré nativement par le moteur "
         "graphique Impeller, sans surcoût."),
        ("Profondeur", ", chaque niveau empile deux ombres, l'une courte pour "
         "l'assise, l'autre longue et très diluée pour la lumière ambiante. "
         "Les opacités restent entre 3 et 8 % : on ne voit pas d'ombre, on "
         "voit une carte qui tient."),
        ("Mouvement", ", les courbes sont celles de la spécification "
         "Material, reprises telles quelles plutôt qu'approchées."),
    ])

    # ------------------------------------------------------------------
    titre(document, "4. L'identité visuelle")

    ligne(document,
        "Une fois le socle sain, l'interface restait interchangeable : on "
        "aurait pu la plaquer sur n'importe quelle place de marché. Le "
        "diagnostic tenait en deux constats. D'abord, tout se trouvait à la "
        "même altitude visuelle, chaque écran empilant des blocs blancs de "
        "même poids sur du blanc. Ensuite, le noir de la charte n'existait que "
        "sur les boutons, alors qu'il en porte la moitié de l'identité.",
        espace_apres=10)

    ligne(document,
        "Un point de marché a orienté le choix : en Côte d'Ivoire, la "
        "combinaison orange, noir et blanc est la signature d'Orange CI, "
        "l'opérateur dominant. Pousser l'orange en aplats larges aurait "
        "rapproché l'application de cette charte. L'identité s'ancre donc sur "
        "le noir, l'orange restant rare et tranchant.",
        espace_apres=10)

    titre(document, "4.1 L'ancrage noir", niveau=3)
    ligne(document,
        "Un bloc sombre coiffe désormais l'accueil, identité, accroche, zone "
        "et recherche, et le contenu clair remonte par-dessus en feuille aux "
        "coins arrondis. Ce recouvrement est ce qui fait tenir l'effet : sans "
        "lui, deux surfaces se succéderaient ; avec lui, la claire passe "
        "manifestement devant. Le démarrage et la présentation se font "
        "entièrement sur fond noir, le passage au clair n'intervenant qu'à "
        "l'arrivée dans le catalogue.",
        espace_apres=10)

    titre(document, "4.2 Le motif de réseau", niveau=3)
    ligne(document,
        "Le logo de l'application est une figure de nœuds reliés, « connecter "
        "le marché ». J'en ai fait un motif génératif, dessiné à deux "
        "endroits. En filigrane derrière les blocs sombres, il donne une "
        "matière à la masse noire. Et surtout, il remplace l'icône grise "
        "affichée à la place des photos manquantes : le dessin est dérivé de "
        "l'identifiant de l'annonce, si bien que deux produits ne portent "
        "jamais le même réseau et qu'un même produit retrouve le sien à chaque "
        "affichage.",
        espace_apres=10)

    ligne(document,
        "Cette solution résout un problème concret : le jeu de démonstration "
        "ne comporte aucune photographie, et toutes les vignettes étaient "
        "vides. La grille est ainsi passée d'un alignement de rectangles gris "
        "à une mosaïque de figures distinctes.",
        espace_apres=10)

    capture(document, "v2-10-accueil-produits.png",
            "Grille d'annonces : chaque vignette porte sa propre figure",
            largeur=Cm(7.4))

    # ------------------------------------------------------------------
    titre(document, "5. Les écrans réalisés")

    capture(document, "v2-02-onboarding.png",
            "Présentation, sur fond noir", largeur=Cm(6.6))
    capture(document, "v2-08-choisir-zone.png",
            "Choix manuel de la commune, recours lorsque la géolocalisation "
            "est refusée", largeur=Cm(6.6))
    capture(document, "v2-11-details-produit.png",
            "Fiche produit : prix, tarif de gros et barre d'action",
            largeur=Cm(6.6))
    capture(document, "refonte-16-compte.png",
            "Espace compte, avec l'activation de la vente", largeur=Cm(6.6))

    # ------------------------------------------------------------------
    titre(document, "6. Règles de gestion et campagne de tests")

    ligne(document,
        "Les règles qui touchent au prix sont celles que l'utilisateur "
        "remarque immédiatement : elles sont donc couvertes par des tests "
        "automatisés. La campagne compte soixante-seize tests, répartis en "
        "sept fichiers, tous au vert à la dernière exécution.",
        espace_apres=8)

    tableau(document,
        ["Règle vérifiée", "Comportement attendu"],
        [
            ["Bascule au tarif de gros",
             "Au seuil de quantité, la ligne entière passe au prix de gros ; "
             "redescendre sous le seuil rétablit le prix de détail"],
            ["Valorisation des lignes",
             "Chaque ligne du panier est valorisée indépendamment des autres"],
            ["Frais de livraison",
             "Offerts au-delà de 100 000 FCFA, facturés 5 000 FCFA en deçà"],
            ["Code promotionnel",
             "Un code valide réduit le total ; un code inconnu est refusé sans "
             "effet"],
            ["Réduction affichée",
             "Calculée depuis le prix antérieur ; un prix incohérent est "
             "ignoré"],
            ["Statut d'une offre",
             "Une offre sans réponse au-delà du délai passe à « expirée »"],
            ["Distance",
             "Formule de Haversine, vérifiée sur des trajets connus d'Abidjan"],
            ["Mise en forme",
             "Prix, distances et compteurs, dont l'espace insécable avant la "
             "devise"],
            ["Chargement du catalogue",
             "Contenu distant repris tel quel ; base vide ou injoignable : "
             "repli sur le jeu local, chargement toujours achevé"],
            ["Favoris",
             "Reprise depuis le dépôt, affichage immédiat avant écriture, "
             "retrait au second appui"],
        ])

    titre(document, "6.1 L'organisation de la campagne", niveau=3)

    ligne(document,
        "Les tests sont rangés par nature plutôt que par écran : une règle de "
        "prix ne se vérifie pas comme une mise en page. La commande "
        "« flutter test » exécute l'ensemble en sept secondes, ce qui permet "
        "de la lancer après chaque modification plutôt qu'à la veille de la "
        "remise.",
        espace_apres=8)

    tableau(document,
        ["Fichier", "Nature", "Ce qu'il vérifie"],
        [
            ["regles_metier_test.dart", "Unitaire",
             "Tarif de gros, livraison, codes promotionnels, réduction "
             "affichée, expiration d'une offre"],
            ["panier_test.dart", "Unitaire",
             "Contenu du panier : cumul des quantités, retrait d'une ligne, "
             "panier vidé"],
            ["distance_test.dart", "Unitaire",
             "Formule de Haversine et mise en forme des distances, sur des "
             "trajets connus d'Abidjan"],
            ["formats_test.dart", "Unitaire",
             "Prix, notes et compteurs abrégés, dont l'espace insécable "
             "avant la devise"],
            ["depots_test.dart", "Intégration",
             "Comportement des dépôts par doublure : base vide, base "
             "injoignable, repli sur le jeu local"],
            ["ressources_test.dart", "Ressources",
             "Chaque image citée par le catalogue existe, est déclarée au "
             "manifeste et tient dans un poids raisonnable"],
            ["debordements_test.dart", "Interface",
             "Les écrans tiennent sans débordement sur trois tailles, de "
             "320 × 568 à 412 × 915"],
        ])

    ligne(document,
        "Deux enseignements sont sortis de cette campagne. Le premier tient "
        "aux ressources : déclarer un dossier dans « pubspec.yaml » ne couvre "
        "pas ses sous-dossiers, et l'oubli ne produit aucune erreur à la "
        "compilation, l'image restant simplement vide à l'exécution. Le test "
        "des ressources a relevé plusieurs images dans ce cas, qu'aucune "
        "relecture du code n'aurait signalées.",
        espace_apres=8)

    capture(document, "v2-14-panier-gros.png",
            "La règle vérifiée par les tests, telle qu'elle se voit à "
            "l'écran : au dixième article, la ligne passe à 38 000 FCFA et "
            "la livraison devient gratuite", largeur=Cm(7.4))

    ligne(document,
        "Le second tient aux dépôts. Un contrôleur ne va jamais chercher sa "
        "source de données, il la reçoit à la construction : le test lui "
        "confie donc un dépôt de remplacement qui simule une base vide ou "
        "muette, sans qu'une seule ligne de sa logique ait à changer. C'est "
        "l'architecture décrite au chapitre 2 qui rend ces tests possibles, "
        "et c'est la meilleure justification que j'en aie trouvée.",
        espace_apres=10)

    # ------------------------------------------------------------------
    titre(document, "7. Difficultés rencontrées")

    titre(document, "7.1 Une devise qui change tout", niveau=3)
    ligne(document,
        "Les maquettes fournies affichaient des montants en dollars, hérités "
        "de leur gabarit. Le marché visé étant Abidjan, l'application devait "
        "afficher des francs CFA. Le changement ne se limitait pas au "
        "symbole : « 45 FCFA » pour un ordinateur portable n'a aucun sens. "
        "J'ai donc porté les montants du jeu de démonstration à l'échelle "
        "réelle du marché, ainsi que les seuils de livraison, en préservant "
        "tous les rapports entre prix de détail, prix de gros et prix "
        "antérieur. La devise se place après le nombre, séparée par une espace "
        "insécable pour qu'un prix ne se coupe jamais en fin de ligne.",
        espace_apres=10)

    titre(document, "7.2 Un gel qui n'en était pas un", niveau=3)
    ligne(document,
        "L'application s'est figée à l'écran de connexion, Android signalant "
        "qu'elle ne répondait plus. J'ai d'abord cherché la cause dans le code "
        "d'authentification. Elle était ailleurs : la partition de données de "
        "l'émulateur était saturée à 91 %, au point de faire échouer jusqu'à "
        "l'installation du paquet. Après réinitialisation, le parcours complet "
        "s'est déroulé sans incident. Aucune correction de code n'a été "
        "nécessaire, la leçon étant de vérifier l'environnement avant de "
        "suspecter le programme.",
        espace_apres=10)

    titre(document, "7.3 Des défauts invisibles à la lecture du code",
          niveau=3)
    ligne(document,
        "Plusieurs défauts ne sont apparus qu'à l'exécution, et seule la "
        "mesure des pixels rendus les a expliqués :",
        espace_apres=6)
    puces(document, [
        "Une ligne de démarcation sous la barre de titre : posée hors du fond "
        "texturé, elle ne recevait pas le grain qui assombrit le reste de "
        "l'écran d'autant.",
        "Un assombrissement général : le vignettage, calibré pour un écran "
        "carré, grisaillait toute la largeur d'un écran deux fois plus haut "
        "que large.",
        "Le nom d'une boutique écrit en sombre sur sa couverture sombre, donc "
        "illisible : seul le logo devait chevaucher le bandeau.",
        "Deux prix à six chiffres se disputant une demi-colonne, le second "
        "finissant tronqué ; le prix antérieur est passé sous le prix courant.",
    ])

    titre(document, "7.4 Une police d'icônes à réduire", niveau=3)
    ligne(document,
        "Les icônes fournies par le kit de développement datent de 2018 et "
        "leur dessin trahit l'âge d'une interface. J'ai embarqué les Material "
        "Symbols Rounded, génération courante du catalogue. La police complète "
        "pèse quinze mégaoctets, ce qui est hors de question pour l'usage "
        "visé. Un script la réduit aux soixante-huit glyphes réellement "
        "appelés et fige les axes inutilisés : le fichier retenu pèse "
        "cinquante-neuf kilo-octets, tout en gardant le remplissage pilotable "
        "à l'affichage, une icône pleine et son contour sont le même symbole.",
        espace_apres=10)

    # ------------------------------------------------------------------
    titre(document, "8. Performance")

    ligne(document,
        "Le cahier des charges vise des téléphones d'entrée de gamme. Les "
        "animations ont donc été mesurées en mode profil, le mode de débogage "
        "ne donnant aucune indication utile puisque son code n'est pas "
        "optimisé.",
        espace_apres=8)

    tableau(document,
        ["Situation mesurée", "Images perdues"],
        [
            ["Neuf défilements sur l'accueil complet", "0"],
            ["Trois allers-retours entre une carte et la fiche produit", "0"],
        ])

    ligne(document,
        "Aucune animation ne repeint de grande surface ni ne charge le fil "
        "principal. Le fond texturé est isolé sous une barrière de "
        "redessin pour n'être jamais recalculé lorsque le contenu change.",
        espace_apres=10)

    # ------------------------------------------------------------------
    titre(document, "9. La documentation du projet")

    ligne(document,
        "Un projet qu'on est seul à comprendre est un projet perdu dès qu'on "
        "s'en éloigne quelques semaines. J'ai donc traité la documentation "
        "comme une partie du travail, et non comme une formalité de fin de "
        "parcours. Elle tient sur trois supports, qui ne s'adressent pas au "
        "même lecteur.",
        espace_apres=10)

    titre(document, "9.1 Le fichier README", niveau=3)
    ligne(document,
        "C'est la porte d'entrée du dépôt. Il ne récite pas la liste des "
        "écrans : il explique d'abord le problème auquel l'application "
        "répond, puis les trois contraintes qui ont commandé presque toutes "
        "les décisions techniques, le statut informel qui ne doit rien "
        "bloquer, la proximité comme moteur de découverte, et le réseau "
        "instable.",
        espace_apres=8)

    ligne(document, "Il se lit en neuf parties :", gras=True, espace_apres=6)
    puces(document, [
        ("Le problème", ", le commerce informel du matériel informatique à "
         "Abidjan et ce que les places de marché existantes supposent à tort."),
        ("Les fonctions", ", décrites avec leurs valeurs réelles : seuils de "
         "livraison, tri par proximité, double tarif."),
        ("Les décisions techniques", ", chacune avec sa raison, y compris "
         "celles qui s'écartent du dossier de conception."),
        ("L'organisation du code", ", l'arborescence de « lib/ » commentée "
         "couche par couche."),
        ("Les tests", ", le tableau des sept fichiers et ce que chacun "
         "couvre."),
        ("L'outillage", ", les cinq scripts Python de « tool/ » et leur "
         "rôle."),
        ("L'installation", ", les deux commandes qui suffisent à lancer "
         "l'application, et la marche à suivre pour la brancher sur "
         "Firebase."),
        ("Les limites connues", ", énoncées sans les atténuer : codes "
         "promotionnels vérifiés sur l'appareil, livraison forfaitaire, "
         "paiement non implémenté, règles de sécurité encore en mode test."),
        ("Les crédits", ", licences des polices et du fond cartographique."),
    ])

    ligne(document,
        "La partie qui m'a demandé le plus de réflexion est celle des limites "
        "connues. La tentation est de n'écrire que ce qui fonctionne ; mais "
        "un lecteur qui découvre seul qu'un code promotionnel se contourne "
        "depuis l'appareil perd confiance dans tout le reste du document. "
        "Énoncer la limite, avec la raison et la suite prévue, vaut mieux que "
        "la laisser trouver.",
        espace_apres=10)

    titre(document, "9.2 La documentation dans le code", niveau=3)
    ligne(document,
        "Les commentaires du projet ne redisent pas ce que le code fait déjà "
        "lire : ils expliquent pourquoi il fait ainsi. Chaque contrôleur "
        "porte en tête la règle du cahier des charges dont il a la charge. Le "
        "contrôleur de localisation rappelle qu'un refus de géolocalisation "
        "n'interrompt jamais le parcours ; celui du panier, que le prix d'une "
        "ligne est recalculé par le modèle et non par lui ; le service "
        "Firebase, pourquoi son initialisation est volontairement tolérante.",
        espace_apres=8)

    ligne(document,
        "Les écarts assumés sont documentés à l'endroit où ils s'appliquent, "
        "et non renvoyés à une annexe. Le passage de Socket.io aux flux de "
        "Firestore est expliqué en tête du contrôleur de conversation, là où "
        "un lecteur se posera la question.",
        espace_apres=10)

    titre(document, "9.3 Le rapport, engendré par script", niveau=3)
    ligne(document,
        "Ce rapport n'est pas saisi à la main dans un traitement de texte : "
        "il est produit par « tool/rapport_docx.py », qui reconstruit la "
        "couverture du gabarit D-CLIC et la met en forme, tandis que "
        "« tool/contenu_rapport.py » n'en porte que le texte. La séparation a "
        "une raison pratique : une correction de fond se relit sans risquer "
        "de déranger une bordure, et le document se régénère à l'identique "
        "autant de fois qu'il le faut.",
        espace_apres=10)

    # ------------------------------------------------------------------
    titre(document, "10. L'espace de dépôt")

    ligne(document,
        "Le projet est placé sous gestion de version avec Git, sur une "
        "branche « main ». Le dépôt réunit le code, les ressources, les "
        "captures, l'outillage et ce rapport, soit deux cent soixante-seize "
        "fichiers au premier enregistrement.",
        espace_apres=8)

    ligne(document, "Ce que le dépôt ne contient pas, et pourquoi :",
          gras=True, espace_apres=6)
    tableau(document,
        ["Écarté du dépôt", "Raison"],
        [
            ["build/, .dart_tool/",
             "Produits de compilation : reconstruits par « flutter pub get » "
             "et « flutter build », ils pèseraient des centaines de "
             "mégaoctets pour rien"],
            ["__pycache__/, *.pyc",
             "Cache de l'interpréteur Python, propre à la machine"],
            [".idea/, *.iml",
             "Réglages de l'environnement de développement, personnels"],
            ["~$*.docx, .DS_Store",
             "Fichiers temporaires de Word et du système de fichiers"],
        ])

    ligne(document,
        "Un point mérite d'être signalé plutôt que passé sous silence : le "
        "fichier "
        "« google-services.json » est suivi par le dépôt. Il est nécessaire "
        "pour rebrancher l'application sur Firebase et ne contient pas de "
        "secret au sens strict, les clés qu'il porte étant destinées au "
        "client. Mais la protection réelle repose alors entièrement sur les "
        "règles de sécurité Firestore, aujourd'hui en mode test. Avant tout "
        "usage réel, ce sont ces règles qu'il faut durcir, et non le fichier "
        "qu'il faut cacher.",
        espace_apres=8)

    ligne(document,
        "Le message du premier enregistrement décrit le projet plutôt que "
        "l'action : architecture, sources de données, fonctions, système de "
        "design, tests et outillage. C'est ce qu'un relecteur lira en premier "
        "dans l'historique.",
        espace_apres=10)

    # ------------------------------------------------------------------
    titre(document, "11. La présentation du projet")

    ligne(document,
        "La démonstration suit le parcours d'un acheteur, de l'ouverture de "
        "l'application au panier. Elle se fait sur téléphone, en portrait : "
        "c'est l'usage pour lequel l'interface a été dessinée, et "
        "l'orientation y est verrouillée au démarrage. Les captures de ce "
        "rapport sont prises sur un appareil Android 16 en 1080 × 2400, "
        "l'application y étant installée depuis le paquet de développement.",
        espace_apres=8)

    ligne(document, "Déroulé retenu :", gras=True, espace_apres=6)
    puces(document, [
        "Écran d'ouverture et présentation, sur fond noir, où se posent la "
        "marque et la promesse.",
        "Création de compte ou connexion, formulaire volontairement court, "
        "sans pièce justificative.",
        "Autorisation de localisation, puis, si elle est refusée, choix "
        "manuel de la commune : c'est le moment où se montre que le parcours "
        "ne dépend pas du GPS.",
        "Accueil ordonné par proximité, catégories, annonces et boutiques.",
        "Fiche produit : galerie, tarif de détail et tarif de gros, ajout au "
        "panier.",
        "Négociation avec le vendeur : proposition de prix, contre-offre, "
        "acceptation.",
        "Panier : bascule au tarif de gros au franchissement du seuil, code "
        "promotionnel, frais de livraison offerts au-delà de 100 000 FCFA.",
        "Compte : activation de la vente, sans création d'un second compte.",
    ], numerotees=True)

    capture(document, "v2-05-commencez.png",
            "Entrée dans l'application : aucun document n'est demandé pour "
            "vendre", largeur=Cm(6.6))
    capture(document, "v2-12-negociation.png",
            "Négociation : l'offre de l'acheteur, portée par un message typé",
            largeur=Cm(6.6))

    ligne(document,
        "Une précaution a été prise pour la démonstration elle-même : "
        "l'application démarre sur son jeu de données local dès que Firebase "
        "n'est pas joignable. Une salle sans réseau, une configuration "
        "absente, une coupure au mauvais moment ne peuvent donc pas "
        "interrompre la présentation. Ce repli n'est pas un artifice de "
        "soutenance, c'est le même mécanisme qui sert le mode dégradé exigé "
        "par le cahier des charges.",
        espace_apres=10)

    # ------------------------------------------------------------------
    titre(document, "12. Conclusion")

    ligne(document,
        "Ce projet m'a fait parcourir la chaîne complète du développement "
        "mobile : analyser un besoin, concevoir une architecture, écrire le "
        "code, puis, et c'est la partie que j'avais sous-estimée, vérifier "
        "le résultat sur un appareil réel et corriger ce que la lecture du "
        "code ne révèle jamais.",
        espace_apres=10)

    ligne(document,
        "La leçon principale porte sur la différence entre une interface "
        "propre et une interface qui a du caractère. La première s'obtient en "
        "appliquant des règles : contrastes, espacements, cohérence des "
        "formes. La seconde demande un parti pris, ici l'ancrage sur le noir "
        "et le motif de réseau tiré du logo, et ce parti pris doit se "
        "justifier par le produit lui-même, non par une mode.",
        espace_apres=10)

    ligne(document,
        "J'ai également appris à mesurer plutôt qu'à supposer : les contrastes "
        "au calcul, les couleurs rendues au pixel, les animations en mode "
        "profil. Plusieurs de mes certitudes visuelles se sont révélées "
        "fausses à la vérification, et c'est cette discipline que je retiens "
        "du projet autant que la maîtrise de Flutter.",
        espace_apres=10)

    ligne(document, "Perspectives", gras=True, espace_apres=6)
    puces(document, [
        "Étendre l'ancrage sombre aux écrans de boutique et de panier.",
        "Alimenter le catalogue en photographies réelles.",
        "Mettre en service le paiement mobile, prévu à la version suivante.",
        "Compléter la couverture de tests par des tests d'interface.",
    ])
