import 'package:flutter/material.dart';

import '../../theme/couleurs.dart';
import '../../theme/dimensions.dart';
import '../../theme/formes.dart';
import '../../theme/profondeur.dart';
import '../../theme/symboles.dart';
import '../../theme/typographie.dart';
import 'boutons.dart';
import 'logo.dart';

/// Barre haute de l'accueil : profil, marque, panier.
///
/// La zone courante est rappelée sous la marque. Le cahier des charges veut la
/// proximité visible partout : l'utilisateur doit savoir en permanence d'où
/// sont mesurées les distances qu'on lui montre, et pouvoir en changer.
class EnteteAccueil extends StatelessWidget {
  const EnteteAccueil({
    super.key,
    required this.zone,
    required this.onProfil,
    required this.onPanier,
    required this.onChangerZone,
    this.nombreArticles = 0,
  });

  final String zone;
  final VoidCallback onProfil;
  final VoidCallback onPanier;
  final VoidCallback onChangerZone;
  final int nombreArticles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Espaces.l,
        Espaces.s,
        Espaces.l,
        Espaces.m,
      ),
      child: Row(
        children: [
          _BoutonProfil(onTap: onProfil),
          const SizedBox(width: Espaces.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const LogoMekano(taille: 30),
                const SizedBox(height: 2),
                InkWell(
                  onTap: onChangerZone,
                  borderRadius: Coupes.puce,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Symboles.place,
                        fill: 1,
                        size: 13,
                        color: Couleurs.orange,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          zone,
                          overflow: TextOverflow.ellipsis,
                          style: Typographie.echelle.labelSmall?.copyWith(
                            color: Couleurs.encreDouce,
                            letterSpacing: 0,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Icon(
                        Symboles.keyboardArrowDown,
                        size: 15,
                        color: Couleurs.encrePale,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _BoutonPanier(nombre: nombreArticles, onTap: onPanier),
        ],
      ),
    );
  }
}

/// Avatar menant au compte.
class _BoutonProfil extends StatelessWidget {
  const _BoutonProfil({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Enfoncable(
      child: DecoratedBox(
        decoration: const ShapeDecoration(
          shape: CircleBorder(),
          shadows: Profondeur.contact,
        ),
        child: Material(
          color: Couleurs.blanc,
          shape: const CircleBorder(side: BorderSide(color: Couleurs.filet)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: const SizedBox(
              height: Tailles.avatar,
              width: Tailles.avatar,
              child: Icon(
                Symboles.person,
                fill: 1,
                size: 22,
                color: Couleurs.encreDouce,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Panier, avec sa pastille de comptage.
class _BoutonPanier extends StatelessWidget {
  const _BoutonPanier({required this.nombre, required this.onTap});

  final int nombre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Enfoncable(
          child: DecoratedBox(
            decoration: const ShapeDecoration(
              shape: CircleBorder(),
              shadows: Profondeur.contact,
            ),
            child: Material(
              color: Couleurs.blanc,
              shape: const CircleBorder(side: BorderSide(color: Couleurs.filet)),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: const SizedBox(
                  height: Tailles.avatar,
                  width: Tailles.avatar,
                  child: Icon(
                    Symboles.shoppingCart,
                    size: 21,
                    color: Couleurs.encre,
                  ),
                ),
              ),
            ),
          ),
        ),
        // La pastille surgit au lieu d'apparaître : un article ajouté au
        // panier doit se voir depuis l'autre bout de l'écran.
        Positioned(
          top: -2,
          right: -2,
          child: AnimatedScale(
            scale: nombre > 0 ? 1 : 0,
            duration: Mouvement.rapide,
            curve: Mouvement.courbeRessort,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              constraints: const BoxConstraints(minWidth: 19),
              decoration: BoxDecoration(
                color: Couleurs.orangeVif,
                borderRadius: Coupes.pastille,
                border: Border.all(color: Couleurs.blanc, width: 1.5),
              ),
              child: Text(
                nombre > 99 ? '99+' : '$nombre',
                textAlign: TextAlign.center,
                style: Typographie.echelle.labelSmall?.copyWith(
                  color: Couleurs.blanc,
                  fontSize: 10,
                  letterSpacing: 0,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Titre de section de l'accueil, avec son lien « Voir tout ».
class TitreSection extends StatelessWidget {
  const TitreSection({
    super.key,
    required this.titre,
    this.onVoirTout,
    this.libelleAction = 'Voir tout',
  });

  final String titre;
  final VoidCallback? onVoirTout;
  final String libelleAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Espaces.l,
        Espaces.xl,
        Espaces.s,
        Espaces.m,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(titre, style: Typographie.echelle.titleLarge),
          ),
          if (onVoirTout != null)
            TextButton(
              onPressed: onVoirTout,
              child: Text(libelleAction),
            ),
        ],
      ),
    );
  }
}
