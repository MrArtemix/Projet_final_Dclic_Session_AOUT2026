import 'package:flutter/material.dart';

import '../../models/boutique.dart';
import '../../models/produit.dart';
import '../../theme/couleurs.dart';
import '../../theme/dimensions.dart';
import '../../theme/formes.dart';
import '../../theme/symboles.dart';
import '../../theme/typographie.dart';
import '../../utils/formats.dart';
import '../../theme/profondeur.dart';
import '../communs/boutons.dart';
import 'indicateurs.dart';

/// Carte d'une annonce, telle qu'elle apparaît sur l'accueil et dans les
/// résultats de recherche.
///
/// Hiérarchie voulue par le dossier de conception : le prix et le titre
/// priment, la distance vient juste après, le reste est secondaire.
class CarteProduit extends StatelessWidget {
  const CarteProduit({
    super.key,
    required this.produit,
    required this.onTap,
    this.distanceKm,
    this.estFavori = false,
    this.onFavori,
    this.afficherNote = false,
    this.marqueVol,
  });

  final Produit produit;
  final VoidCallback onTap;

  /// Distance jusqu'à l'utilisateur. Nulle tant que sa position est inconnue.
  final double? distanceKm;

  final bool estFavori;
  final VoidCallback? onFavori;

  /// Affiche la note sur la vignette, comme sur l'écran de résultats.
  final bool afficherNote;

  /// Marque reliant cette vignette à celle de la fiche produit.
  ///
  /// Renseignée, l'image ne disparaît plus au profit d'une autre : elle glisse
  /// de la carte vers la fiche, ce qui dit à l'utilisateur qu'il ouvre
  /// l'annonce qu'il vient de toucher plutôt qu'il change d'écran.
  ///
  /// La marque doit être unique **par écran** : un même produit peut figurer à
  /// la fois parmi les annonces proches et parmi les promotions, et deux
  /// marques identiques sur une même page lèvent une erreur. D'où un préfixe
  /// de section, à transmettre tel quel à la fiche.
  final String? marqueVol;

  @override
  Widget build(BuildContext context) {
    final reduction = produit.pourcentageReduction;

    // La carte est blanche sur un fond creusé : c'est cet écart de ton qui la
    // détache. L'ombre de contact ne fait que confirmer qu'elle repose là, et
    // dispense du trait qui la cernait jusqu'ici.
    return Enfoncable(
      child: DecoratedBox(
        decoration: const ShapeDecoration(
          color: Couleurs.blanc,
          shape: Formes.carte,
          shadows: Profondeur.contact,
        ),
        child: Material(
          color: Colors.transparent,
          shape: Formes.carte,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    if (marqueVol == null)
                      ImageProduit(
                        url: produit.photos.isEmpty ? '' : produit.photos.first,
                        hauteur: 130,
                        signature: produit.id,
                      )
                    else
                      Hero(
                        tag: marqueVol!,
                        child: ImageProduit(
                          url: produit.photos.isEmpty
                              ? ''
                              : produit.photos.first,
                          hauteur: 130,
                          signature: produit.id,
                        ),
                      ),
                    // Voile sombre au pied de la vignette : sans lui, un badge
                    // clair posé sur une photo claire devient illisible.
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 56,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0x14140E08), Color(0x00140E08)],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (onFavori != null)
                      Positioned(
                        top: Espaces.s,
                        right: Espaces.s,
                        child: _BoutonFavori(
                          actif: estFavori,
                          onTap: onFavori!,
                        ),
                      ),
                    if (afficherNote && produit.note > 0)
                      Positioned(
                        left: Espaces.s,
                        bottom: Espaces.s,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Espaces.s,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Couleurs.blanc.withValues(alpha: 0.94),
                            borderRadius: Coupes.pastille,
                            border: Border.all(color: Couleurs.filet),
                          ),
                          child: NoteEtoiles(
                            note: produit.note,
                            taille: 12,
                            afficherEtoiles: false,
                          ),
                        ),
                      ),
                    if (reduction != null)
                      Positioned(
                        top: Espaces.s,
                        left: Espaces.s,
                        child: BadgeReduction(pourcentage: reduction),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(Espaces.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        produit.titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Typographie.echelle.titleMedium,
                      ),
                      const SizedBox(height: Espaces.s),
                      // Le prix antérieur passe sous le prix courant plutôt
                      // qu'à côté : accolés sur une demi-colonne, deux montants
                      // à six chiffres se disputent la largeur et le second
                      // finit tronqué.
                      Text(
                        Formats.prix(produit.prixDetail),
                        style: Typographie.prixCarte,
                      ),
                      if (produit.prixAvant != null)
                        Text(
                          Formats.prix(produit.prixAvant!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Typographie.prixBarre,
                        ),
                      // La ligne du prix antérieur a repris la hauteur que
                      // cette respiration occupait : la carte déborderait de
                      // deux pixels si on la laissait à sa valeur pleine.
                      const SizedBox(height: Espaces.xs),
                      EtiquetteDistance(distanceKm: distanceKm, compact: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cœur de mise en favori, posé sur la vignette d'une carte produit.
class _BoutonFavori extends StatelessWidget {
  const _BoutonFavori({required this.actif, required this.onTap});

  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Le fond suit l'état : un cœur qui se remplit sans que rien d'autre ne
    // bouge passe inaperçu sur une vignette chargée.
    return AnimatedContainer(
      duration: Mouvement.rapide,
      curve: Mouvement.courbe,
      decoration: ShapeDecoration(
        color: actif
            ? Couleurs.orangePale
            : Couleurs.blanc.withValues(alpha: 0.94),
        shape: CircleBorder(
          side: BorderSide(
            color: actif ? Couleurs.orangeClair : Couleurs.filet,
          ),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 32,
            width: 32,
            child: AnimatedSwitcher(
              duration: Mouvement.rapide,
              // Le cœur dépasse sa taille avant de s'y poser : c'est ce
              // dépassement, et lui seul, qui donne au geste sa sensation
              // d'aboutissement.
              switchInCurve: Mouvement.courbeRessort,
              transitionBuilder: (enfant, animation) => ScaleTransition(
                scale: Tween<double>(begin: 0.4, end: 1).animate(animation),
                child: enfant,
              ),
              child: Icon(
                Symboles.favorite,
                fill: actif ? 1 : 0,
                key: ValueKey(actif),
                size: 17,
                color: actif ? Couleurs.orangeVif : Couleurs.encre,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Carte d'une boutique partenaire, telle qu'elle apparaît sur l'accueil.
class CarteBoutique extends StatelessWidget {
  const CarteBoutique({
    super.key,
    required this.boutique,
    required this.onTap,
    this.distanceKm,
    this.suivie = false,
    this.onSuivre,
  });

  final Boutique boutique;
  final VoidCallback onTap;
  final double? distanceKm;
  final bool suivie;
  final VoidCallback? onSuivre;

  @override
  Widget build(BuildContext context) {
    return Enfoncable(
      child: DecoratedBox(
        decoration: const ShapeDecoration(
          color: Couleurs.blanc,
          shape: Formes.carte,
          shadows: Profondeur.contact,
        ),
        child: Material(
          color: Colors.transparent,
          shape: Formes.carte,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(Espaces.m),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: Coupes.puce,
                    child: SizedBox(
                      height: 56,
                      width: 56,
                      child: ImageProduit(
                    url: boutique.logo,
                    signature: boutique.id,
                    hauteurAffichee: 56,
                  ),
                    ),
                  ),
                  const SizedBox(width: Espaces.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                boutique.nom,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Typographie.echelle.titleMedium,
                              ),
                            ),
                            if (boutique.verifiee) ...[
                              const SizedBox(width: Espaces.xs),
                              const BadgeVerifie(taille: 14),
                            ],
                          ],
                        ),
                        Text(
                          boutique.categorie,
                          style: Typographie.echelle.bodySmall,
                        ),
                        const SizedBox(height: Espaces.s),
                        Row(
                          children: [
                            NoteEtoiles(note: boutique.note, taille: 13),
                            const SizedBox(width: Espaces.m),
                            Flexible(
                              child: EtiquetteDistance(
                                distanceKm: distanceKm,
                                compact: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onSuivre != null) ...[
                    const SizedBox(width: Espaces.s),
                    _BoutonSuivre(suivie: suivie, onTap: onSuivre!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bouton « Suivre » d'une carte boutique.
///
/// Suivre engage l'utilisateur : le bouton porte donc le noir de l'action
/// principale. Une fois la boutique suivie, il repasse en secondaire.
class _BoutonSuivre extends StatelessWidget {
  const _BoutonSuivre({required this.suivie, required this.onTap});

  final bool suivie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: suivie ? Couleurs.blanc : Couleurs.noir,
      borderRadius: Coupes.puce,
      child: InkWell(
        onTap: onTap,
        borderRadius: Coupes.puce,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Espaces.l,
            vertical: Espaces.s + 2,
          ),
          decoration: BoxDecoration(
            borderRadius: Coupes.puce,
            border: Border.all(
              color: suivie ? Couleurs.filetMarque : Colors.transparent,
            ),
          ),
          child: Text(
            suivie ? 'Suivi' : 'Suivre',
            style: Typographie.echelle.labelMedium?.copyWith(
              color: suivie ? Couleurs.encre : Couleurs.blanc,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
