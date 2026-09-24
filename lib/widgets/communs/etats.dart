import 'package:flutter/material.dart';

import '../../theme/couleurs.dart';
import '../../theme/dimensions.dart';
import '../../theme/formes.dart';
import '../../theme/symboles.dart';
import '../../theme/typographie.dart';
import 'boutons.dart';

/// Écran ou section sans contenu à afficher.
///
/// Le dossier de conception insiste sur des parcours qui ne s'interrompent
/// jamais brutalement : un résultat vide propose toujours une issue.
class EtatVide extends StatelessWidget {
  const EtatVide({
    super.key,
    required this.icone,
    required this.titre,
    this.message,
    this.libelleAction,
    this.onAction,
  });

  final IconData icone;
  final String titre;
  final String? message;
  final String? libelleAction;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Espaces.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                // Un aplat uni paraît collé sur le fond ; un dégradé très
                // court lui donne l'épaisseur d'un creux.
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Couleurs.blancChamp, Couleurs.blancCreux],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Couleurs.filet),
              ),
              child: Icon(icone, size: 32, color: Couleurs.encreDouce),
            ),
            const SizedBox(height: Espaces.l),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: Typographie.echelle.titleLarge,
            ),
            if (message != null) ...[
              const SizedBox(height: Espaces.s),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Typographie.echelle.bodyMedium,
              ),
            ],
            if (libelleAction != null && onAction != null) ...[
              const SizedBox(height: Espaces.xl),
              BoutonSecondaire(
                libelle: libelleAction!,
                onPressed: onAction,
                pleineLargeur: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Indicateur d'activité centre, aux couleurs de la charte.
class EtatChargement extends StatelessWidget {
  const EtatChargement({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          if (message != null) ...[
            const SizedBox(height: Espaces.l),
            Text(message!, style: Typographie.echelle.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// Erreur de chargement, avec possibilité de relancer.
///
/// Le cahier des charges prévoit des connexions instables : chaque échec de
/// lecture doit pouvoir être retenté sans quitter l'écran.
class EtatErreur extends StatelessWidget {
  const EtatErreur({super.key, required this.message, this.onReessayer});

  final String message;
  final VoidCallback? onReessayer;

  @override
  Widget build(BuildContext context) {
    return EtatVide(
      icone: Symboles.wifiOff,
      titre: 'Chargement impossible',
      message: message,
      libelleAction: onReessayer == null ? null : 'Réessayer',
      onAction: onReessayer,
    );
  }
}

/// Bloc animé qui tient la place d'un contenu en cours de chargement.
///
/// Préférable à un indicateur tournant sur les listes : la page garde sa
/// structure, ce qui évite un saut de mise en page à l'arrivée des données.
///
/// L'animation est un balayage, et non une pulsation d'ensemble. La nuance
/// compte : une surface qui clignote signale une attente, une lueur qui
/// traverse signale un travail en cours. La seconde lecture est celle que l'on
/// veut, et c'est aussi celle qui fatigue le moins l'œil sur une liste
/// entière de blocs.
class BlocSquelette extends StatefulWidget {
  const BlocSquelette({
    super.key,
    this.hauteur = 16,
    this.largeur,
    this.rayon,
  });

  final double hauteur;
  final double? largeur;
  final BorderRadius? rayon;

  @override
  State<BlocSquelette> createState() => _BlocSqueletteState();
}

class _BlocSqueletteState extends State<BlocSquelette>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controleur = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controleur,
        builder: (context, _) {
          // La lueur part hors du bloc, le traverse, et en ressort : d'où une
          // course de -2 à 2 plutôt que de 0 à 1.
          final double course = _controleur.value * 4 - 2;

          return Container(
            height: widget.hauteur,
            width: widget.largeur,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(course - 1, 0),
                end: Alignment(course + 1, 0),
                colors: const [
                  Couleurs.blancCreux,
                  Couleurs.blancChamp,
                  Couleurs.blancCreux,
                ],
                stops: const [0.35, 0.5, 0.65],
              ),
              borderRadius: widget.rayon ?? Coupes.puce,
            ),
          );
        },
      ),
    );
  }
}
