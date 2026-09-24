import 'package:flutter/material.dart';

import '../../theme/couleurs.dart';
import '../../theme/dimensions.dart';
import '../../theme/formes.dart';
import '../../theme/profondeur.dart';
import '../../theme/typographie.dart';

/// Enfoncement d'une action sous le doigt.
///
/// Material 3 ne prévoit qu'une onde d'encre au toucher. Elle se voit mal sur
/// un aplat noir, et pas du tout sur une surface sombre en plein soleil. Un
/// retrait d'échelle de trois pour cent, lui, se sent : l'élément cède sous le
/// doigt et reprend sa place, ce qui suffit à confirmer l'appui.
///
/// Le geste n'est pas intercepté : un [Listener] observe le pointeur sans
/// le consommer, et l'action posée à l'intérieur reçoit ses événements
/// normalement.
class Enfoncable extends StatefulWidget {
  const Enfoncable({
    super.key,
    required this.child,
    this.actif = true,
    this.echelle = 0.97,
  });

  final Widget child;

  /// À faux, l'enfoncement est neutralisé : action désactivée ou en cours.
  final bool actif;

  /// Échelle atteinte au creux de l'appui.
  final double echelle;

  @override
  State<Enfoncable> createState() => _EnfoncableState();
}

class _EnfoncableState extends State<Enfoncable> {
  bool _enfonce = false;

  void _poser(bool valeur) {
    if (!widget.actif || _enfonce == valeur) return;
    setState(() => _enfonce = valeur);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _poser(true),
      onPointerUp: (_) => _poser(false),
      onPointerCancel: (_) => _poser(false),
      child: AnimatedScale(
        scale: _enfonce ? widget.echelle : 1,
        duration: Mouvement.instantane,
        curve: Mouvement.courbe,
        child: widget.child,
      ),
    );
  }
}

/// Indicateur d'activité posé dans une action.
///
/// Reprend le dessin courant des indicateurs Material, piste interrompue
/// devant la tête de lecture, dont le thème fixe déjà les couleurs.
class _Activite extends StatelessWidget {
  const _Activite({required this.couleur});

  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        strokeCap: StrokeCap.round,
        color: couleur,
        backgroundColor: couleur.withValues(alpha: 0.24),
      ),
    );
  }
}

/// Action principale d'un écran : fond noir, pleine largeur.
///
/// La charte réserve le noir aux actions qui engagent l'utilisateur : ajouter
/// au panier, passer la commande, suivre une boutique, confirmer une zone. Un
/// écran ne comporte qu'une seule action de ce rang.
class BoutonPrincipal extends StatelessWidget {
  const BoutonPrincipal({
    super.key,
    required this.libelle,
    required this.onPressed,
    this.icone,
    this.enChargement = false,
    this.pleineLargeur = true,
  });

  final String libelle;

  /// Passer `null` désactive le bouton.
  final VoidCallback? onPressed;

  /// Icône facultative, posée avant le libellé.
  final IconData? icone;

  /// Remplace le contenu par un indicateur d'activité et bloque l'appui.
  final bool enChargement;

  final bool pleineLargeur;

  @override
  Widget build(BuildContext context) {
    final actif = onPressed != null && !enChargement;

    final bouton = DecoratedBox(
      decoration: ShapeDecoration(
        shape: Formes.bouton,
        // L'ombre n'est posée que sur un bouton actif : désactivé, il doit
        // paraître à plat, donc inerte.
        shadows: actif ? Profondeur.contact : Profondeur.aucune,
      ),
      child: FilledButton(
        onPressed: enChargement ? null : onPressed,
        style: pleineLargeur
            ? null
            : FilledButton.styleFrom(
                minimumSize: const Size(0, Tailles.bouton),
                padding: const EdgeInsets.symmetric(horizontal: Espaces.xl),
              ),
        child: enChargement
            ? const _Activite(couleur: Couleurs.blanc)
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icone != null) ...[
                    Icon(icone, size: 20, color: Couleurs.blanc),
                    const SizedBox(width: Espaces.s),
                  ],
                  Text(libelle),
                ],
              ),
      ),
    );

    return Enfoncable(
      actif: actif,
      child: pleineLargeur
          ? SizedBox(width: double.infinity, child: bouton)
          : bouton,
    );
  }
}

/// Action secondaire : contour fin sur fond blanc.
class BoutonSecondaire extends StatelessWidget {
  const BoutonSecondaire({
    super.key,
    required this.libelle,
    required this.onPressed,
    this.icone,
    this.pleineLargeur = true,
    this.surFondSombre = false,
  });

  final String libelle;
  final VoidCallback? onPressed;
  final IconData? icone;
  final bool pleineLargeur;

  /// Inverse le contour et l'encre, pour une pose sur bloc sombre. Le fond
  /// reste transparent : sur du noir, une surface blanche ferait une action
  /// principale, ce que ce bouton n'est pas.
  final bool surFondSombre;

  @override
  Widget build(BuildContext context) {
    final encre = surFondSombre ? Couleurs.encreInverse : Couleurs.encre;

    final bouton = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: encre,
        backgroundColor: surFondSombre ? Colors.transparent : Couleurs.blanc,
        side: BorderSide(
          color: surFondSombre ? Couleurs.filetNuit : Couleurs.filetMarque,
          width: surFondSombre ? 1.5 : 1,
        ),
        minimumSize: pleineLargeur
            ? const Size.fromHeight(Tailles.bouton)
            : const Size(0, Tailles.bouton),
        padding: pleineLargeur
            ? null
            : const EdgeInsets.symmetric(horizontal: Espaces.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 20, color: encre),
            const SizedBox(width: Espaces.s),
          ],
          Text(libelle),
        ],
      ),
    );

    return Enfoncable(
      actif: onPressed != null,
      child: pleineLargeur
          ? SizedBox(width: double.infinity, child: bouton)
          : bouton,
    );
  }
}

/// Action accentuée, en orange plein.
///
/// Emploi restreint : les maquettes ne l'utilisent que pour « Créer un
/// compte », « Se connecter » et « Appliquer » un code promo, où l'orange
/// signale un gain pour l'utilisateur.
class BoutonAccentue extends StatelessWidget {
  const BoutonAccentue({
    super.key,
    required this.libelle,
    required this.onPressed,
    this.enChargement = false,
    this.pleineLargeur = true,
    this.attenue = false,
  });

  final String libelle;
  final VoidCallback? onPressed;
  final bool enChargement;
  final bool pleineLargeur;

  /// Variante claire, employée lorsque deux actions orange se suivent et qu'il
  /// faut les départager, comme sur l'écran « Commencez maintenant ».
  final bool attenue;

  @override
  Widget build(BuildContext context) {
    final actif = onPressed != null && !enChargement;

    final bouton = DecoratedBox(
      decoration: ShapeDecoration(
        shape: Formes.bouton,
        // Ombre teintée : sous un aplat orange, une ombre grise ternit la
        // couleur au lieu de l'asseoir.
        shadows: actif && !attenue
            ? Profondeur.halo(Couleurs.orange)
            : Profondeur.aucune,
      ),
      child: FilledButton(
        onPressed: enChargement ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: attenue
              ? Couleurs.orange.withValues(alpha: 0.65)
              : Couleurs.orange,
          foregroundColor: Couleurs.blanc,
          minimumSize: pleineLargeur
              ? const Size.fromHeight(Tailles.bouton)
              : const Size(0, Tailles.bouton),
          padding: pleineLargeur
              ? null
              : const EdgeInsets.symmetric(horizontal: Espaces.xl),
          elevation: 0,
          shape: Formes.bouton,
          textStyle: Typographie.echelle.labelLarge,
        ),
        child: enChargement
            ? const _Activite(couleur: Couleurs.blanc)
            : Text(libelle.toUpperCase()),
      ),
    );

    return Enfoncable(
      actif: actif,
      child: pleineLargeur
          ? SizedBox(width: double.infinity, child: bouton)
          : bouton,
    );
  }
}

/// Barre d'action ancrée au bas d'un écran.
///
/// Trois écrans engagent l'utilisateur depuis le bas de la page : confirmer sa
/// zone, ajouter au panier, passer commande. L'action y reste atteignable au
/// pouce pendant que le contenu défile derrière.
///
/// Encore faut-il qu'elle se détache de ce contenu. Une barre simplement
/// posée laisse voir les lignes passer dessous, et l'on ne sait plus ce qui
/// appartient à la page ou à l'action. D'où la surface pleine, l'ombre
/// projetée vers le haut, et la marge basse qui tient compte du geste de
/// navigation du système.
class BarreAction extends StatelessWidget {
  const BarreAction({super.key, required this.child, this.recapitulatif});

  /// Action principale de la barre.
  final Widget child;

  /// Contenu posé au-dessus de l'action : total du panier, prix retenu.
  final Widget? recapitulatif;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Couleurs.blanc,
        boxShadow: Profondeur.barre,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Espaces.l,
            Espaces.m,
            Espaces.l,
            Espaces.m,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (recapitulatif != null) ...[
                recapitulatif!,
                const SizedBox(height: Espaces.m),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Bouton rond d'appoint : retour, favori, appel, menu.
///
/// Repris tel quel des maquettes, où il apparaît posé sur l'image d'un produit
/// ou dans la barre haute d'un écran.
class BoutonRond extends StatelessWidget {
  const BoutonRond({
    super.key,
    required this.icone,
    required this.onPressed,
    this.couleurIcone,
    this.couleurFond,
    this.infobulle,
    this.remplissage = 0,
    this.pose = true,
  });

  final IconData icone;
  final VoidCallback? onPressed;

  /// Remplissage du glyphe, de 0 pour un contour à 1 pour un aplat. La police
  /// d'icônes étant variable, l'état actif d'un bouton, un favori posé, par
  /// exemple, se lit ainsi sans changer de symbole.
  final double remplissage;

  final Color? couleurIcone;
  final Color? couleurFond;
  final String? infobulle;

  /// À vrai, le bouton porte une ombre de contact. À couper lorsqu'il est
  /// posé sur une surface déjà élevée, où l'ombre ferait doublon.
  final bool pose;

  @override
  Widget build(BuildContext context) {
    final bouton = DecoratedBox(
      decoration: ShapeDecoration(
        shape: const CircleBorder(),
        shadows: pose ? Profondeur.contact : Profondeur.aucune,
      ),
      child: Material(
        color: couleurFond ?? Couleurs.blanc,
        shape: const CircleBorder(side: BorderSide(color: Couleurs.filet)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: Tailles.boutonRond,
            width: Tailles.boutonRond,
            child: Icon(
              icone,
              fill: remplissage,
              size: 20,
              color: couleurIcone ?? Couleurs.encre,
            ),
          ),
        ),
      ),
    );

    final enfoncable = Enfoncable(actif: onPressed != null, child: bouton);

    return infobulle == null
        ? enfoncable
        : Tooltip(message: infobulle!, child: enfoncable);
  }
}
