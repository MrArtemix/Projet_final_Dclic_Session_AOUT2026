import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/couleurs.dart';

/// Motif de nœuds reliés, signature graphique de l'application.
///
/// Le logo de Mekano Afrika est un réseau : des nœuds tenus par des arêtes,
/// pour « connecter le marché ». Le motif reprend cette figure et la décline à
/// deux endroits où l'interface manquait de caractère.
///
/// **Derrière un bloc sombre**, tracé à peine visible, il donne une matière à
/// la masse noire, sans lui, un aplat de cette taille paraît peint au
/// rouleau.
///
/// **À la place d'une photo manquante**, il remplace l'icône grise qui
/// s'affichait jusqu'ici. Le dessin est *dérivé de l'identifiant de l'annonce*
/// : deux produits ne portent jamais le même réseau, et le même produit
/// retrouve le sien à chaque affichage. Une liste d'annonces sans photo cesse
/// ainsi d'être une grille de rectangles vides pour devenir une mosaïque.
///
/// Le tirage est volontairement pauvre, une suite congruentielle tenant en
/// trois lignes, plutôt que `Random` : il doit rester identique d'une version
/// de Dart à l'autre, sans quoi la vignette d'un produit changerait de dessin
/// au fil des mises à jour.
class MotifReseau extends StatelessWidget {
  const MotifReseau({
    super.key,
    required this.graine,
    this.surSombre = false,
    this.densite = 7,
    this.intensite = 1,
  });

  /// Détermine le dessin. Passer l'identifiant d'un produit, sa chaîne étant
  /// convertie en nombre par [grainePour].
  final int graine;

  /// Inverse les couleurs pour une pose sur bloc sombre.
  final bool surSombre;

  /// Nombre de nœuds. Au-delà d'une dizaine, la figure devient une toile et
  /// perd sa lisibilité.
  final int densite;

  /// Facteur d'opacité, pour atténuer le motif là où il ne doit qu'affleurer.
  final double intensite;

  /// Convertit une chaîne en graine stable.
  static int grainePour(String valeur) {
    var accumulation = 7;
    for (final unite in valeur.codeUnits) {
      accumulation = (accumulation * 31 + unite) & 0x7FFFFFFF;
    }
    return accumulation;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _PeintreReseau(
          graine: graine,
          surSombre: surSombre,
          densite: densite,
          intensite: intensite,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _PeintreReseau extends CustomPainter {
  _PeintreReseau({
    required this.graine,
    required this.surSombre,
    required this.densite,
    required this.intensite,
  });

  final int graine;
  final bool surSombre;
  final int densite;
  final double intensite;

  /// Suite congruentielle linéaire, reproductible d'une version à l'autre.
  static int _suivant(int etat) => (etat * 1103515245 + 12345) & 0x7FFFFFFF;

  @override
  void paint(Canvas toile, Size taille) {
    if (taille.isEmpty) return;

    // Les nœuds sont tirés dans une marge intérieure : un nœud collé au bord
    // se lit comme une salissure plutôt que comme une figure.
    final marge = math.min(taille.width, taille.height) * 0.14;
    final aire = Rect.fromLTRB(
      marge,
      marge,
      taille.width - marge,
      taille.height - marge,
    );

    var etat = _suivant(graine);
    final noeuds = <Offset>[];
    final rayons = <double>[];

    for (var i = 0; i < densite; i++) {
      etat = _suivant(etat);
      final x = aire.left + (etat % 1000) / 1000 * aire.width;
      etat = _suivant(etat);
      final y = aire.top + (etat % 1000) / 1000 * aire.height;
      etat = _suivant(etat);
      noeuds.add(Offset(x, y));
      rayons.add(2.5 + (etat % 100) / 100 * 3.5);
    }

    final couleurTrait = surSombre
        ? Couleurs.orange.withValues(alpha: 0.30 * intensite)
        : Couleurs.orange.withValues(alpha: 0.28 * intensite);
    final couleurNoeud = surSombre
        ? Couleurs.orange.withValues(alpha: 0.55 * intensite)
        : Couleurs.orange.withValues(alpha: 0.42 * intensite);

    final trait = Paint()
      ..color = couleurTrait
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    final pastille = Paint()..color = couleurNoeud;

    // Chaque nœud rejoint le plus proche de ceux qui le suivent : le graphe
    // reste connexe sans jamais se refermer en toile d'araignée.
    for (var i = 0; i < noeuds.length; i++) {
      var meilleur = -1;
      var distanceMin = double.infinity;
      for (var j = i + 1; j < noeuds.length; j++) {
        final d = (noeuds[i] - noeuds[j]).distance;
        if (d < distanceMin) {
          distanceMin = d;
          meilleur = j;
        }
      }
      if (meilleur >= 0) toile.drawLine(noeuds[i], noeuds[meilleur], trait);
    }

    for (var i = 0; i < noeuds.length; i++) {
      toile.drawCircle(noeuds[i], rayons[i], pastille);
    }

    // Un nœud domine : c'est lui qui donne son centre de gravité à la figure.
    final dominant = graine % noeuds.length;
    toile.drawCircle(
      noeuds[dominant],
      rayons[dominant] + 3.5,
      Paint()..color = Couleurs.orange.withValues(alpha: 0.85 * intensite),
    );
    toile.drawCircle(
      noeuds[dominant],
      rayons[dominant] + 7.5,
      Paint()
        ..color = Couleurs.orange.withValues(alpha: 0.30 * intensite)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_PeintreReseau ancien) =>
      ancien.graine != graine ||
      ancien.surSombre != surSombre ||
      ancien.densite != densite ||
      ancien.intensite != intensite;
}
