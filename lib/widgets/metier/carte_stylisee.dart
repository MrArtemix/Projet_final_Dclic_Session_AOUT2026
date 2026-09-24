import '../../theme/symboles.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/couleurs.dart';

/// Carte géographique stylisée, dessinée par l'application.
///
/// Le dossier de conception prévoyait Google Maps ou Mapbox. Les deux exigent
/// une clé d'interface de programmation, une facturation et une connexion
/// active, trois contraintes lourdes pour la version initiale, et contraires
/// à la sobriété réseau demandée. La carte est donc dessinée localement : elle
/// situe la zone et son rayon de recherche, ce dont les écrans ont besoin,
/// sans aucune dépendance externe.
///
/// Le tracé est déterministe : la même zone produit toujours le même dessin.
class CarteStylisee extends StatelessWidget {
  const CarteStylisee({
    super.key,
    required this.nomZone,
    this.hauteur = 200,
    this.rayonKm,
  });

  /// Nom de la zone, qui sert aussi de germe au tracé des rues.
  final String nomZone;

  final double hauteur;

  /// Rayon de recherche à matérialiser autour du repère.
  final double? rayonKm;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: hauteur,
        width: double.infinity,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _PeintreCarte(germe: nomZone.hashCode),
            child: Center(
              child: _Repere(rayonKm: rayonKm),
            ),
          ),
        ),
      ),
    );
  }
}

/// Repère de position, avec son halo de portée.
class _Repere extends StatelessWidget {
  const _Repere({this.rayonKm});

  final double? rayonKm;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (rayonKm != null)
          Container(
            height: 128,
            width: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Couleurs.orange.withValues(alpha: 0.10),
              border: Border.all(
                color: Couleurs.orange.withValues(alpha: 0.35),
              ),
            ),
          ),
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: Couleurs.noir,
            shape: BoxShape.circle,
            border: Border.all(color: Couleurs.blanc, width: 2.5),
          ),
          child: const Icon(Symboles.place, fill: 1, size: 20, color: Couleurs.orange),
        ),
      ],
    );
  }
}

/// Tracé du fond de carte : blocs, voies et plan d'eau.
class _PeintreCarte extends CustomPainter {
  const _PeintreCarte({required this.germe});

  /// Germe du générateur : garantit un tracé stable pour une même zone.
  final int germe;

  @override
  void paint(Canvas toile, Size taille) {
    final alea = math.Random(germe);

    // Fond du plan.
    toile.drawRect(
      Offset.zero & taille,
      Paint()..color = const Color(0xFFF7F6F3),
    );

    // Îlots bâtis : de simples blocs clairs, assez nombreux pour évoquer un
    // tissu urbain, assez discrets pour ne pas concurrencer le repère.
    final peintureBloc = Paint()..color = const Color(0xFFEFEDE8);
    for (var i = 0; i < 26; i++) {
      final x = alea.nextDouble() * taille.width;
      final y = alea.nextDouble() * taille.height;
      final largeur = 18 + alea.nextDouble() * 46;
      final hauteur = 14 + alea.nextDouble() * 34;
      toile.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, largeur, hauteur),
          const Radius.circular(3),
        ),
        peintureBloc,
      );
    }

    // Voies principales, en blanc, horizontales et verticales.
    final peintureVoie = Paint()
      ..color = Couleurs.blanc
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final y = taille.height * (0.22 + i * 0.28);
      toile.drawLine(Offset(0, y), Offset(taille.width, y), peintureVoie);
    }
    for (var i = 0; i < 3; i++) {
      final x = taille.width * (0.2 + i * 0.3);
      toile.drawLine(Offset(x, 0), Offset(x, taille.height), peintureVoie);
    }

    // Une diagonale, pour rompre la régularité de la trame.
    toile.drawLine(
      Offset(-10, taille.height * 0.82),
      Offset(taille.width * 0.75, -10),
      peintureVoie..strokeWidth = 5,
    );

    // Plan d'eau dans un angle : la lagune d'Abidjan est un repère visuel
    // immédiat pour les utilisateurs de la ville.
    final eau = Path()
      ..moveTo(taille.width * 0.62, taille.height)
      ..quadraticBezierTo(
        taille.width * 0.86,
        taille.height * 0.80,
        taille.width,
        taille.height * 0.86,
      )
      ..lineTo(taille.width, taille.height)
      ..close();
    toile.drawPath(eau, Paint()..color = const Color(0xFFDCE7EC));
  }

  @override
  bool shouldRepaint(_PeintreCarte ancien) => ancien.germe != germe;
}
