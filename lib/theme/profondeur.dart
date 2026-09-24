import 'package:flutter/material.dart';

import 'couleurs.dart';

/// Ombres de l'application.
///
/// La charte interdit l'ombre portée appuyée, et elle a raison : une ombre
/// franche sur un fond blanc salit la surface. Ce que l'on cherche n'est pas
/// une ombre mais un **contact**, l'indice qu'une surface repose sur une
/// autre plutôt que d'être peinte dessus.
///
/// Chaque niveau empile deux ombres plutôt qu'une :
///
/// * une ombre courte et presque opaque, qui dessine l'assise de la surface ;
/// * une ombre longue et très diluée, qui suggère la lumière ambiante.
///
/// C'est cet empilement qui distingue une interface soignée d'un `elevation:
/// 4` posé au hasard. Les opacités restent comprises entre 3 et 8 % : à
/// hauteur d'œil, on ne voit aucune ombre, on voit une carte qui tient.
///
/// La teinte est celle de [Couleurs.ombre], un brun très foncé : sur les
/// blancs chauds de l'application, une ombre noire tire au gris bleuté.
class Profondeur {
  const Profondeur._();

  /// Surface simplement posée : carte produit, carte boutique, tuile.
  static const List<BoxShadow> contact = [
    BoxShadow(
      color: Color(0x0A140E08),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x08140E08),
      blurRadius: 1,
    ),
  ];

  /// Surface soulevée : carte pressée, élément saisi, vignette mise en avant.
  static const List<BoxShadow> flottant = [
    BoxShadow(
      color: Color(0x0D140E08),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0D140E08),
      blurRadius: 20,
      spreadRadius: -4,
      offset: Offset(0, 8),
    ),
  ];

  /// Barre d'action ancrée au bas de l'écran.
  ///
  /// L'ombre est projetée vers le haut : c'est le contenu qui passe dessous,
  /// et la barre doit s'en détacher sans qu'un trait la souligne.
  static const List<BoxShadow> barre = [
    BoxShadow(
      color: Color(0x14140E08),
      blurRadius: 32,
      spreadRadius: -12,
      offset: Offset(0, -8),
    ),
  ];

  /// Halo orange, pour une action principale teintée ou une vignette active.
  ///
  /// Une ombre colorée sous un élément orange lui donne une assise que le gris
  /// rendrait terne.
  static List<BoxShadow> halo(Color couleur) => [
        BoxShadow(
          color: couleur.withValues(alpha: 0.22),
          blurRadius: 16,
          spreadRadius: -6,
          offset: const Offset(0, 6),
        ),
      ];

  /// Aucune ombre. Rend l'intention explicite là où une surface doit rester
  /// strictement à plat.
  static const List<BoxShadow> aucune = [];
}
