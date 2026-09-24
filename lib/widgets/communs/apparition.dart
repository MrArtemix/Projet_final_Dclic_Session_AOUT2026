import 'package:flutter/material.dart';

import '../../theme/dimensions.dart';

/// Entrée en scène d'un élément : un fondu doublé d'une courte montée.
///
/// L'effet tient en deux gestes et doit le rester. Un contenu qui apparaît
/// **en montant** se lit comme arrivant de sous la ligne de flottaison, dans
/// le sens où l'on fait défiler ; la même apparition en descendant contredit
/// le geste. La course est volontairement brève, une douzaine de points, le
/// temps d'un battement : au-delà, l'écran donne l'impression de se remplir
/// au ralenti, ce qui use après trois ouvertures.
///
/// Le décalage entre voisins produit la cascade. [rang] suffit à l'obtenir :
/// chaque élément attend quarante millisecondes de plus que le précédent, et
/// le retard est plafonné pour que le dernier d'une longue liste n'attende pas
/// une seconde entière.
///
/// ## Pourquoi pas de contrôleur
///
/// Un seul `TweenAnimationBuilder` porte l'ensemble : le retard est obtenu par
/// un `Interval` sur la courbe plutôt que par un minuteur. Il n'y a donc ni
/// état à gérer, ni contrôleur à libérer, ni risque qu'une animation continue
/// de tourner après le démontage de son widget, ce qui compte sur la liste
/// d'un téléphone d'entrée de gamme.
///
/// ## Ce qu'elle ne fait pas
///
/// L'animation se joue au montage, non à l'entrée dans le champ de vision :
/// détecter la visibilité demanderait une dépendance de plus pour un gain
/// invisible, puisque les éléments situés plus bas sont déjà en place quand le
/// lecteur les atteint. Pour la même raison, elle n'a pas sa place dans une
/// liste à recyclage, où elle se rejouerait à chaque retour en arrière.
class Apparition extends StatelessWidget {
  const Apparition({
    super.key,
    required this.child,
    this.rang = 0,
    this.course = 12,
    this.actif = true,
  });

  final Widget child;

  /// Position dans la cascade. Zéro démarre immédiatement.
  final int rang;

  /// Distance parcourue à la montée, en points.
  final double course;

  /// À faux, l'enfant est rendu tel quel. Sert à couper l'effet là où il
  /// gênerait, un rechargement de liste, par exemple.
  final bool actif;

  /// Retard accordé à chaque rang.
  static const Duration _pas = Duration(milliseconds: 40);

  /// Au-delà, les retards cessent de s'accumuler.
  static const int _rangMaximal = 8;

  @override
  Widget build(BuildContext context) {
    if (!actif) return child;

    final retard = _pas * (rang.clamp(0, _rangMaximal));
    final totale = retard + Mouvement.rapide;
    final debut = totale.inMicroseconds == 0
        ? 0.0
        : retard.inMicroseconds / totale.inMicroseconds;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: totale,
      curve: Interval(debut, 1, curve: Mouvement.courbe),
      builder: (context, avancement, enfant) {
        return Opacity(
          opacity: avancement,
          child: Transform.translate(
            offset: Offset(0, (1 - avancement) * course),
            child: enfant,
          ),
        );
      },
      child: child,
    );
  }
}
