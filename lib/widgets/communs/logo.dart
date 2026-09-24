import 'package:flutter/material.dart';

import '../../theme/couleurs.dart';
import '../../theme/dimensions.dart';
import '../../theme/symboles.dart';
import '../../theme/typographie.dart';

/// Marque de l'application.
///
/// Le logo a deux états, et non deux dessins. En grand — démarrage,
/// présentation — la [constellation] entière est visible : le disque central
/// relié à ses satellites, qui dit le réseau de vendeurs proches. Partout
/// ailleurs, seul le disque est repris : au-dessous d'une cinquantaine de
/// pixels, les antennes ne sont plus qu'une poussière illisible, et le
/// monogramme doit rester reconnaissable jusque dans une barre d'en-tête.
///
/// Les trois fichiers sont dérivés du logo d'origine par
/// `tool/preparer_logo.py`, qui les recentre, accorde leurs teintes à la charte
/// et éclaircit les liaisons destinées aux fonds noirs.
class LogoMekano extends StatelessWidget {
  const LogoMekano({
    super.key,
    this.taille = 48,
    this.avecNom = true,
    this.nomEnColonne = false,
    this.surFondSombre = false,
    this.constellation = false,
  });

  /// Côté de la marque.
  final double taille;

  /// Affiche « Mekano Afrika » à côté du monogramme.
  final bool avecNom;

  /// Dispose le nom sous le monogramme plutôt qu'à côté, comme sur l'écran de
  /// chargement.
  final bool nomEnColonne;

  /// Inverse l'encre du nom et des liaisons, pour une pose sur bloc sombre.
  /// L'orange, lui, ne change pas : c'est la constante de la marque.
  final bool surFondSombre;

  /// Affiche la figure complète plutôt que le seul disque. À réserver aux
  /// écrans qui lui laissent la place.
  final bool constellation;

  /// Taille de la constellation proportionnée à l'appareil.
  ///
  /// Une valeur fixe ne convient pas : posée sur un écran de 320 points, la
  /// figure de 190 chasse le reste de la colonne hors de l'écran et fait
  /// apparaître les barres de débordement. La part de largeur est donc bornée
  /// des deux côtés — assez grande pour rester une entrée en matière, assez
  /// petite pour laisser vivre ce qui l'accompagne.
  static double tailleDeploye(BuildContext context) =>
      (MediaQuery.sizeOf(context).width * 0.52).clamp(120.0, 190.0);

  @override
  Widget build(BuildContext context) {
    final monogramme = _Marque(
      taille: taille,
      constellation: constellation,
      surFondSombre: surFondSombre,
    );

    if (!avecNom) return monogramme;

    // Le nom s'accorde au disque, pas au cadre de l'image. La constellation
    // entoure ce disque d'antennes et de vide : accordé à sa taille pleine, le
    // nom écraserait la figure qu'il accompagne.
    final tailleOptique = constellation ? taille * 0.52 : taille;

    final nom = _NomMarque(
      taille: nomEnColonne ? tailleOptique * 0.46 : tailleOptique * 0.40,
      centre: nomEnColonne,
      inverse: surFondSombre,
    );

    if (nomEnColonne) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          monogramme,
          SizedBox(height: tailleOptique * 0.34),
          nom,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        monogramme,
        SizedBox(width: tailleOptique * 0.28),
        nom,
      ],
    );
  }
}

/// Figure de la marque : le disque seul, ou la constellation entière.
class _Marque extends StatelessWidget {
  const _Marque({
    required this.taille,
    required this.constellation,
    required this.surFondSombre,
  });

  static const _dossier = 'assets/images/logo_mekano';

  final double taille;
  final bool constellation;
  final bool surFondSombre;

  /// Le disque central est blanc et cerné de noir : il se pose tel quel sur
  /// fond clair comme sur fond sombre. Seule la constellation a besoin d'une
  /// variante, ses liaisons noires s'effaçant sur le bloc nuit.
  String get _fichier {
    if (!constellation) return '$_dossier/mekano_afrika_monogramme.png';
    return surFondSombre
        ? '$_dossier/mekano_afrika_sur_sombre.png'
        : '$_dossier/mekano_afrika_complet.png';
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _fichier,
      height: taille,
      width: taille,
      // La source fait 512 px et se retrouve souvent réduite au dixième : sans
      // filtrage de qualité, l'anneau du disque se met à grésiller.
      filterQuality: FilterQuality.medium,
      semanticLabel: 'Mekano Afrika',
    );
  }
}

/// « Mekano » en orange, « Afrika » en encre.
class _NomMarque extends StatelessWidget {
  const _NomMarque({
    required this.taille,
    required this.centre,
    this.inverse = false,
  });

  final double taille;
  final bool centre;
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: Typographie.famille,
      fontSize: taille,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.5,
    );
    final encre = inverse ? Couleurs.encreInverse : Couleurs.encre;

    if (centre) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Mekano', style: style.copyWith(color: Couleurs.orange)),
          Text('Afrika', style: style.copyWith(color: encre)),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Mekano', style: style.copyWith(color: Couleurs.orange)),
        SizedBox(width: taille * 0.22),
        Text('Afrika', style: style.copyWith(color: encre)),
      ],
    );
  }
}

/// Bandeau de marque posé en haut des écrans d'authentification.
class EnteteMarque extends StatelessWidget {
  const EnteteMarque({super.key, this.onRetour});

  /// Flèche de retour, affichée seulement si une action est fournie.
  final VoidCallback? onRetour;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Espaces.l,
        vertical: Espaces.m,
      ),
      // Le logo est centré sur la largeur entière et le bouton posé par-dessus,
      // plutôt que mis en balance avec un contrepoids invisible : celui-ci
      // réservait 96 points quelle que soit la place restante, et la ligne
      // débordait de l'écran sur un téléphone étroit.
      child: Stack(
        alignment: Alignment.center,
        children: [
          const LogoMekano(taille: 38),
          if (onRetour != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onRetour,
                icon: const Icon(Symboles.arrowBack, size: 18),
                label: const Text('Retour'),
              ),
            ),
        ],
      ),
    );
  }
}
