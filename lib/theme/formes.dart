import 'package:flutter/material.dart';

import 'dimensions.dart';

/// Formes de l'application.
///
/// Toutes les surfaces de Mekano Afrika sont découpées dans la même famille
/// de courbes : la **superellipse arrondie**, dite squircle. Là où un coin
/// arrondi ordinaire raccorde un segment droit à un arc de cercle, laissant
/// voir la rupture de courbure, la superellipse fait varier son rayon de
/// façon continue. Le coin paraît alors plus doux à rayon égal, et une carte
/// posée sur un fond clair cesse d'avoir l'air découpée à l'emporte-pièce.
///
/// Le rendu est assuré nativement par Impeller : la forme ne coûte pas plus
/// cher qu'un rectangle arrondi, ce qui importe sur le matériel d'entrée de
/// gamme visé par le cahier des charges.
///
/// Deux familles cohabitent, par nécessité :
///
/// * [Formes] rend des `OutlinedBorder`, attendus par les composants Material
///   (`Card`, `FilledButton`, `Dialog`, `BottomSheet`) ;
/// * [Coupes] rend des `BorderRadius`, attendus par `Container`, `ClipRRect`
///   et `InkWell`.
///
/// Les deux dérivent des mêmes rayons, déclarés une fois dans `Rayons`.
class Formes {
  const Formes._();

  /// Forme d'une puce de filtre ou d'une petite vignette.
  static const OutlinedBorder puce = RoundedSuperellipseBorder(
    borderRadius: BorderRadius.all(Radius.circular(Rayons.s)),
  );

  /// Forme d'une carte produit, d'une carte boutique, d'une tuile de réglage.
  static const OutlinedBorder carte = RoundedSuperellipseBorder(
    borderRadius: BorderRadius.all(Radius.circular(Rayons.m)),
  );

  /// Forme d'un champ de saisie.
  static const OutlinedBorder champ = RoundedSuperellipseBorder(
    borderRadius: BorderRadius.all(Radius.circular(Rayons.l)),
  );

  /// Forme d'un bouton : entièrement arrondi.
  ///
  /// La pastille est la signature des actions de Material 3. Sur une action
  /// pleine largeur, elle allège une masse noire que des coins à rayon moyen
  /// rendraient pesante.
  static const OutlinedBorder bouton = StadiumBorder();

  /// Forme d'une feuille remontante ou d'un dialogue.
  static const OutlinedBorder feuille = RoundedSuperellipseBorder(
    borderRadius: BorderRadius.all(Radius.circular(Rayons.xl)),
  );

  /// Forme du haut d'une feuille ancrée au bas de l'écran.
  static const OutlinedBorder feuilleHaute = RoundedSuperellipseBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(Rayons.xl)),
  );

}

/// Rayons de découpe, pour les widgets qui attendent un `BorderRadius`.
///
/// Le rendu d'un `ClipRRect` reste un arrondi circulaire : la superellipse
/// n'existe que sur les `ShapeBorder`, pas sur les `BorderRadius`. L'écart ne se voit pas sous vingt
/// points de rayon ; au-delà, préférer une forme de [Formes] portée par un
/// `Material` plutôt qu'une découpe.
class Coupes {
  const Coupes._();

  static const BorderRadius badge = BorderRadius.all(Radius.circular(Rayons.xs));
  static const BorderRadius puce = BorderRadius.all(Radius.circular(Rayons.s));
  static const BorderRadius carte = BorderRadius.all(Radius.circular(Rayons.m));
  static const BorderRadius champ = BorderRadius.all(Radius.circular(Rayons.l));
  static const BorderRadius feuille = BorderRadius.all(Radius.circular(Rayons.xl));
  static const BorderRadius pastille = BorderRadius.all(Radius.circular(Rayons.rond));

  /// Haut d'une feuille ancrée au bas de l'écran.
  static const BorderRadius feuilleHaute = BorderRadius.vertical(
    top: Radius.circular(Rayons.xl),
  );

  /// Bulle d'un message : le coin tourné vers son auteur se resserre.
  static BorderRadius bulle({required bool emise}) => BorderRadius.only(
        topLeft: const Radius.circular(Rayons.m),
        topRight: const Radius.circular(Rayons.m),
        bottomLeft: Radius.circular(emise ? Rayons.m : Rayons.xs),
        bottomRight: Radius.circular(emise ? Rayons.xs : Rayons.m),
      );
}
