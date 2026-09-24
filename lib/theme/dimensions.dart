import 'package:flutter/material.dart';

/// Espacements, rayons et rythme de l'interface.
///
/// Toutes les valeurs dérivent d'une base de quatre points, ce qui garantit un
/// alignement constant d'un écran à l'autre. Écrire une marge en dur ailleurs
/// dans le projet casse ce rythme : passer par cette classe.
class Espaces {
  const Espaces._();

  /// 4 : séparation minimale, entre une icône et son libellé.
  static const double xs = 4;

  /// 8 : entre deux éléments d'un même groupe.
  static const double s = 8;

  /// 12 : intérieur des puces et des petites cartes.
  static const double m = 12;

  /// 16 : marge latérale de référence des écrans.
  static const double l = 16;

  /// 24 : entre deux blocs d'une même section.
  static const double xl = 24;

  /// 32 : entre deux sections.
  static const double xxl = 32;

  /// 48 : respiration des écrans d'onboarding.
  static const double xxxl = 48;

  /// Marge latérale appliquée au contenu de tous les écrans.
  static const EdgeInsets ecran = EdgeInsets.symmetric(horizontal: l);
}

/// Rayons de courbure.
///
/// Material 3 fait de la forme un signal à part entière : plus un élément est
/// interactif et proche de l'utilisateur, plus son rayon est généreux.
///
/// Ces valeurs ne sont pas employées directement : elles alimentent `Formes`
/// et `Coupes`, qui décident du rendu, superellipse pour une surface,
/// arrondi circulaire pour une découpe.
class Rayons {
  const Rayons._();

  /// 8 : badges et étiquettes.
  static const double xs = 8;

  /// 14 : puces de filtre, petites vignettes.
  static const double s = 14;

  /// 18 : cartes produit et cartes boutique.
  static const double m = 18;

  /// 20 : champs de saisie.
  static const double l = 20;

  /// 28 : feuilles remontantes et grandes surfaces.
  static const double xl = 28;

  /// Entièrement arrondi : pastilles et avatars. Pour un bouton, préférer
  /// `Formes.bouton`, qui suit la hauteur réelle de l'élément.
  static const double rond = 999;
}

/// Durées et courbes du mouvement.
///
/// Les courbes sont celles de la spécification Material, exposées par le SDK
/// sous `Easing` : une entrée doit être vive puis se poser, jamais linéaire.
/// Les reprendre telles quelles vaut mieux que de les approcher avec les
/// courbes génériques de `Curves`, l'écart se voit sur une transition
/// d'écran, où l'arrivée paraît molle d'une dizaine de millisecondes.
///
/// Les durées restent courtes : le cahier des charges vise des appareils
/// d'entrée de gamme, où une animation longue passe pour une lenteur.
class Mouvement {
  const Mouvement._();

  /// 120 ms, retour au doigt : enfoncement, bascule d'un favori.
  static const Duration instantane = Duration(milliseconds: 120);

  /// 200 ms, apparition d'un élément dans une liste.
  static const Duration rapide = Duration(milliseconds: 200);

  /// 300 ms, transition entre deux écrans.
  static const Duration normal = Duration(milliseconds: 300);

  /// 500 ms, mise en scène d'un écran d'onboarding.
  static const Duration ample = Duration(milliseconds: 500);

  /// Courbe par défaut : départ franc, arrivée posée.
  static const Curve courbe = Easing.standardDecelerate;

  /// Courbe accentuée, pour ce qui entre dans le champ et doit s'y installer :
  /// feuille remontante, carte qui se déplie, élément mis en avant.
  static const Curve courbeRessort = Easing.emphasizedDecelerate;

}

/// Hauteurs récurrentes, pour que deux écrans ne divergent pas d'un pixel.
class Tailles {
  const Tailles._();

  /// Hauteur d'un bouton principal pleine largeur.
  static const double bouton = 56;

  /// Hauteur d'un champ de saisie.
  static const double champ = 56;

  /// Hauteur de la barre de recherche de l'accueil.
  static const double barreRecherche = 48;

  /// Côté d'un bouton rond d'appoint : retour, favori, appel.
  static const double boutonRond = 44;

  /// Hauteur d'une puce de filtre.
  static const double puce = 38;

  /// Côté de l'avatar d'un vendeur dans une liste.
  static const double avatar = 44;

  /// Hauteur de la barre d'action basse : total et action principale.
  static const double barreAction = 88;
}
