import 'package:flutter/material.dart';

import 'couleurs.dart';

/// Échelle typographique de Mekano Afrika, bâtie sur Inter.
///
/// L'échelle reprend les rôles de Material 3 (`displayLarge` jusqu'à
/// `labelSmall`), ce qui permet aux composants du SDK de se styler tout seuls.
/// Les tailles sont resserrées par rapport aux valeurs par défaut de Material :
/// les maquettes sont denses et destinées à de petits écrans.
///
/// Règle de hiérarchie retenue dans le dossier de conception : l'information
/// principale, prix et titre, doit primer nettement sur le reste.
///
/// ## Les chiffres ne bougent pas
///
/// Tout ce qui se compare d'une ligne à l'autre, prix, distance, quantité,
/// compteur, est composé en chiffres tabulaires : chaque chiffre y occupe la
/// même largeur. Sans cela, une colonne de prix ondule dès qu'un `1` succède
/// à un `8`, et un compteur qui s'incrémente fait sautiller ce qui l'entoure.
/// C'est un détail que l'on ne remarque qu'une fois corrigé.
class Typographie {
  const Typographie._();

  static const String famille = 'Inter';

  /// Chiffres à chasse fixe. Inter les fournit ; il suffit de les demander.
  static const List<FontFeature> _chiffresAlignes = [
    FontFeature.tabularFigures(),
  ];

  /// Interlignes : serrés sur les titres, aérés sur les paragraphes pour
  /// rester lisibles en pleine lumière.
  static const double _serre = 1.15;
  static const double _normal = 1.35;
  static const double _aere = 1.5;

  static const TextTheme echelle = TextTheme(
    // Écrans d'onboarding : la promesse du produit.
    displayLarge: TextStyle(
      fontFamily: famille,
      fontSize: 36,
      fontWeight: FontWeight.w700,
      height: _serre,
      // Le tracking se resserre à mesure que le corps grandit : à cette
      // taille, l'espacement par défaut d'Inter délite le mot.
      letterSpacing: -0.9,
      color: Couleurs.encre,
    ),
    displayMedium: TextStyle(
      fontFamily: famille,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: _serre,
      letterSpacing: -0.6,
      color: Couleurs.encre,
    ),

    // Titres d'écran et prix mis en avant.
    headlineLarge: TextStyle(
      fontFamily: famille,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.3,
      color: Couleurs.encre,
    ),
    headlineMedium: TextStyle(
      fontFamily: famille,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: -0.2,
      color: Couleurs.encre,
    ),

    // Titres de section : « Produits près de chez vous ».
    titleLarge: TextStyle(
      fontFamily: famille,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: -0.2,
      color: Couleurs.encre,
    ),
    // Titre d'une carte produit.
    titleMedium: TextStyle(
      fontFamily: famille,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: _normal,
      color: Couleurs.encre,
    ),
    titleSmall: TextStyle(
      fontFamily: famille,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: _normal,
      color: Couleurs.encre,
    ),

    // Paragraphes : description d'un produit, message d'une conversation.
    bodyLarge: TextStyle(
      fontFamily: famille,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: _aere,
      color: Couleurs.encre,
    ),
    bodyMedium: TextStyle(
      fontFamily: famille,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: _aere,
      color: Couleurs.encreDouce,
    ),
    bodySmall: TextStyle(
      fontFamily: famille,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: _normal,
      color: Couleurs.encreDouce,
    ),

    // Libellés : boutons, puces, distances, badges.
    labelLarge: TextStyle(
      fontFamily: famille,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.1,
      color: Couleurs.encre,
    ),
    labelMedium: TextStyle(
      fontFamily: famille,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.2,
      color: Couleurs.encreDouce,
    ),
    labelSmall: TextStyle(
      fontFamily: famille,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.4,
      color: Couleurs.encrePale,
    ),
  );

  // --- Styles métier --------------------------------------------------------
  // Ces trois styles portent la règle de couleur de la charte : ils sont
  // utilisés tels quels par les composants, sans redéfinition locale.

  /// Prix affiché : information principale d'une annonce.
  static const TextStyle prix = TextStyle(
    fontFamily: famille,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.5,
    color: Couleurs.encre,
    fontFeatures: _chiffresAlignes,
  );

  /// Prix d'une carte produit, plus compact.
  static const TextStyle prixCarte = TextStyle(
    fontFamily: famille,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.3,
    color: Couleurs.encre,
    fontFeatures: _chiffresAlignes,
  );

  /// Prix barré avant réduction.
  ///
  /// Nettement plus petit que le prix courant : posés côte à côte sur une
  /// carte, deux montants de même corps se disputent le regard, et le second
  /// finit tronqué faute de place.
  static const TextStyle prixBarre = TextStyle(
    fontFamily: famille,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: Couleurs.encrePale,
    decoration: TextDecoration.lineThrough,
    decorationColor: Couleurs.encrePale,
    fontFeatures: _chiffresAlignes,
  );

  /// Distance jusqu'au vendeur : mise en avant de la proximité, exigée sur
  /// chaque écran pertinent par le cahier des charges.
  static const TextStyle distance = TextStyle(
    fontFamily: famille,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: Couleurs.orangeTexte,
    fontFeatures: _chiffresAlignes,
  );

  /// Intitulé de section en capitales, tel qu'il apparaît sur l'écran compte.
  static const TextStyle sectionCapitales = TextStyle(
    fontFamily: famille,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.8,
    color: Couleurs.encrePale,
  );

  /// Accroche d'un bloc sombre : la plus grande ligne de l'application.
  ///
  /// Le tracking se resserre à mesure que le corps grandit, à trente-deux
  /// points, l'espacement par défaut d'Inter délite le mot. L'interligne
  /// descend sous l'unité de hauteur : une accroche de deux lignes doit se
  /// lire comme un bloc, pas comme deux phrases.
  static const TextStyle accroche = TextStyle(
    fontFamily: famille,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -1.1,
    color: Couleurs.encreInverse,
  );

  /// Quantité, compteur, décompte : tout nombre qui varie sous les yeux.
  static const TextStyle compteur = TextStyle(
    fontFamily: famille,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: Couleurs.encre,
    fontFeatures: _chiffresAlignes,
  );
}
