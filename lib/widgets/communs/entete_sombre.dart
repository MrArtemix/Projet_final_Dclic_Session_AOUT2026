import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/couleurs.dart';
import '../../theme/dimensions.dart';
import '../../theme/formes.dart';
import '../../theme/profondeur.dart';
import '../../theme/symboles.dart';
import '../../theme/typographie.dart';
import 'apparition.dart';
import 'boutons.dart';
import 'motif_reseau.dart';
import 'logo.dart';

/// Bloc sombre qui coiffe les écrans principaux.
///
/// La charte annonce « noir et orange ». Tant que le noir se limitait aux
/// boutons, chaque écran se lisait comme une pile de blocs blancs posés sur du
/// blanc : propre, mais sans rien pour accrocher le regard ni pour distinguer
/// l'application de n'importe quelle autre place de marché.
///
/// Ce bloc donne au noir une masse. Il porte l'identité, la zone, l'accroche et
/// la recherche ; le contenu clair de l'écran remonte ensuite par-dessus, dont
/// les coins supérieurs s'arrondissent, d'où l'impression d'une feuille posée
/// sur le noir, et une hiérarchie immédiate entre ce qui situe l'utilisateur et
/// ce qu'il vient chercher.
///
/// Sur un tel fond, l'orange de marque atteint enfin 6:1 : il peut porter du
/// texte, ce que le fond clair lui interdisait.
class EnteteSombre extends StatelessWidget {
  const EnteteSombre({
    super.key,
    required this.accroche,
    this.zone,
    this.onChangerZone,
    this.actions = const [],
    this.contenuBas,
    this.marque = true,
  });

  /// Phrase d'accroche, posée en grand. C'est elle qui donne le ton de l'écran.
  final String accroche;

  /// Zone courante, rappelée sous la marque. Le cahier des charges veut la
  /// proximité visible partout : l'utilisateur doit savoir en permanence d'où
  /// sont mesurées les distances qu'on lui montre, et pouvoir en changer.
  final String? zone;
  final VoidCallback? onChangerZone;

  /// Boutons ronds posés à droite de la ligne de marque.
  final List<Widget> actions;

  /// Contenu ancré au bas du bloc : la barre de recherche, le plus souvent.
  final Widget? contenuBas;

  /// À faux, la ligne de marque disparaît au profit du seul titre. Sert aux
  /// écrans secondaires, qui n'ont pas à réafficher l'enseigne.
  final bool marque;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // L'heure et les indicateurs du système passent en clair : sur un fond
      // noir, les laisser sombres les rendrait illisibles.
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Couleurs.nuitHaute, Couleurs.nuit],
          ),
        ),
        child: Stack(
          children: [
            // Le réseau de la marque, tracé à peine visible dans l'angle que
            // le texte laisse libre : sans lui, un aplat de cette taille
            // paraît peint au rouleau.
            Positioned(
              top: -40,
              right: -70,
              width: 320,
              height: 300,
              child: IgnorePointer(
                child: MotifReseau(
                  graine: 20260918,
                  surSombre: true,
                  densite: 9,
                  intensite: 0.55,
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                // La marge basse est généreuse : la feuille claire viendra en
                // recouvrir une partie, et il doit rester de l'air sous la
                // recherche une fois ce recouvrement déduit.
                padding: const EdgeInsets.fromLTRB(
                  Espaces.l,
                  Espaces.l,
                  Espaces.l,
                  Espaces.xxl + Espaces.m,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (marque) ...[
                      Apparition(
                        child: Row(
                          children: [
                            const LogoMekano(taille: 30, surFondSombre: true),
                            const Spacer(),
                            ...actions,
                          ],
                        ),
                      ),
                      const SizedBox(height: Espaces.xl),
                    ],
                    Apparition(
                      rang: 1,
                      child: Text(accroche, style: Typographie.accroche),
                    ),
                    if (zone != null) ...[
                      const SizedBox(height: Espaces.m),
                      Apparition(
                        rang: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _Zone(zone: zone!, onTap: onChangerZone),
                        ),
                      ),
                    ],
                    if (contenuBas != null) ...[
                      const SizedBox(height: Espaces.xl),
                      Apparition(rang: 3, child: contenuBas!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Zone courante, ouvrant le choix d'une autre commune.
class _Zone extends StatelessWidget {
  const _Zone({required this.zone, this.onTap});

  final String zone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Couleurs.surfaceNuit,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Espaces.m, 7, Espaces.m, 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Symboles.place,
                fill: 1,
                size: 15,
                color: Couleurs.orange,
              ),
              const SizedBox(width: Espaces.xs),
              Text(
                zone,
                style: Typographie.echelle.labelMedium?.copyWith(
                  color: Couleurs.encreInverse,
                  fontSize: 13,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 2),
                const Icon(
                  Symboles.keyboardArrowDown,
                  size: 16,
                  color: Couleurs.encreInverseDouce,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Bouton rond posé sur un bloc sombre.
///
/// Le [BoutonRond] ordinaire est blanc cerné d'un filet : sur du noir, il
/// ferait une tache. Celui-ci reprend la surface sombre du bloc.
class BoutonRondSombre extends StatelessWidget {
  const BoutonRondSombre({
    super.key,
    required this.icone,
    required this.onPressed,
    this.badge = 0,
    this.infobulle,
  });

  final IconData icone;
  final VoidCallback? onPressed;

  /// Compte affiché en pastille. À zéro, aucune pastille n'est posée.
  final int badge;

  final String? infobulle;

  @override
  Widget build(BuildContext context) {
    final bouton = Enfoncable(
      actif: onPressed != null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Couleurs.surfaceNuit,
            shape: const CircleBorder(
              side: BorderSide(color: Couleurs.filetNuit),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox(
                height: Tailles.avatar,
                width: Tailles.avatar,
                child: Icon(icone, size: 21, color: Couleurs.encreInverse),
              ),
            ),
          ),
          // La pastille surgit au lieu d'apparaître : un article ajouté au
          // panier doit se voir depuis l'autre bout de l'écran.
          Positioned(
            top: -2,
            right: -2,
            child: AnimatedScale(
              scale: badge > 0 ? 1 : 0,
              duration: Mouvement.rapide,
              curve: Mouvement.courbeRessort,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                constraints: const BoxConstraints(minWidth: 19),
                decoration: BoxDecoration(
                  color: Couleurs.orange,
                  borderRadius: Coupes.pastille,
                  border: Border.all(color: Couleurs.nuit, width: 1.5),
                  boxShadow: Profondeur.halo(Couleurs.orange),
                ),
                child: Text(
                  badge > 99 ? '99+' : '$badge',
                  textAlign: TextAlign.center,
                  style: Typographie.echelle.labelSmall?.copyWith(
                    color: Couleurs.encreInverse,
                    fontSize: 10,
                    letterSpacing: 0,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return infobulle == null
        ? bouton
        : Tooltip(message: infobulle!, child: bouton);
  }
}

/// Feuille claire qui remonte sur le bloc sombre.
///
/// Le recouvrement est ce qui fait tenir l'effet : sans lui, deux surfaces se
/// succéderaient simplement ; avec lui, la claire passe manifestement devant.
class FeuilleClaire extends StatelessWidget {
  const FeuilleClaire({super.key, required this.child, this.recouvrement = 28});

  final Widget child;

  /// De combien la feuille mord sur le bloc sombre.
  final double recouvrement;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -recouvrement),
      child: Container(
        decoration: const BoxDecoration(
          color: Couleurs.fond,
          borderRadius: Coupes.feuilleHaute,
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
