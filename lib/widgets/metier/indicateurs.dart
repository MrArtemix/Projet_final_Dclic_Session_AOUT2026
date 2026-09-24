import 'package:flutter/material.dart';

import '../../models/produit.dart';
import '../../theme/couleurs.dart';
import '../../theme/dimensions.dart';
import '../../theme/formes.dart';
import '../../theme/profondeur.dart';
import '../../theme/symboles.dart';
import '../../theme/typographie.dart';
import '../communs/motif_reseau.dart';
import '../../utils/distance.dart';
import '../../utils/formats.dart';

/// Pastille indiquant l'état d'un produit : neuf, occasion ou bradé.
///
/// Le cahier des charges demande que ces trois états se distinguent au premier
/// regard : chacun porte sa propre couleur, déclarée dans la charte.
class BadgeEtat extends StatelessWidget {
  const BadgeEtat({super.key, required this.etat, this.compact = false});

  final EtatProduit etat;

  /// Version réduite, posée sur une vignette de carte produit.
  final bool compact;

  Color get _couleur => switch (etat) {
        EtatProduit.neuf => Couleurs.etatNeuf,
        EtatProduit.occasion => Couleurs.etatOccasion,
        EtatProduit.brade => Couleurs.etatBrade,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? Espaces.s : Espaces.m,
        vertical: compact ? 3 : Espaces.xs,
      ),
      decoration: BoxDecoration(
        color: _couleur.withValues(alpha: 0.10),
        borderRadius: Coupes.pastille,
        border: Border.all(color: _couleur.withValues(alpha: 0.22)),
      ),
      child: Text(
        etat.libelle,
        style: Typographie.echelle.labelSmall?.copyWith(
          color: _couleur,
          fontSize: compact ? 10 : 11,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Badge de réduction, en orange plein.
///
/// Repris des maquettes de la fiche produit, où il accompagne le prix barré.
class BadgeReduction extends StatelessWidget {
  const BadgeReduction({super.key, required this.pourcentage});

  final int pourcentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Espaces.s,
        vertical: Espaces.xs,
      ),
      decoration: BoxDecoration(
        color: Couleurs.orangeVif,
        borderRadius: Coupes.pastille,
        // Le badge est posé sur une photo dont on ignore le ton : une ombre
        // courte lui garantit un bord net, quel que soit le fond.
        boxShadow: Profondeur.contact,
      ),
      child: Text(
        '-$pourcentage%',
        style: Typographie.echelle.labelSmall?.copyWith(
          color: Couleurs.blanc,
          fontSize: 12,
          letterSpacing: 0,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Distance jusqu'au vendeur, précédée d'un repère de localisation.
///
/// La proximité est le moteur de découverte de l'application : cette étiquette
/// apparaît sur chaque annonce, chaque boutique et chaque résultat.
class EtiquetteDistance extends StatelessWidget {
  const EtiquetteDistance({
    super.key,
    required this.distanceKm,
    this.commune,
    this.compact = false,
  });

  /// Distance en kilomètres. Nulle lorsque la position de l'utilisateur n'est
  /// pas encore connue : l'étiquette se replie alors sur la seule commune.
  final double? distanceKm;

  final String? commune;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final texte = [
      if (distanceKm != null) Distance.formater(distanceKm!),
      if (commune != null && commune!.isNotEmpty) commune!,
    ].join(' · ');

    if (texte.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Symboles.place,
          fill: 1,
          size: compact ? 12 : 14,
          color: Couleurs.orange,
        ),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            texte,
            overflow: TextOverflow.ellipsis,
            style: Typographie.distance.copyWith(
              fontSize: compact ? 11 : 12,
              color: commune == null ? Couleurs.orange : Couleurs.encreDouce,
            ),
          ),
        ),
      ],
    );
  }
}

/// Note d'un vendeur ou d'un produit, en étoiles.
class NoteEtoiles extends StatelessWidget {
  const NoteEtoiles({
    super.key,
    required this.note,
    this.nbAvis,
    this.taille = 14,
    this.afficherEtoiles = true,
  });

  final double note;
  final int? nbAvis;
  final double taille;

  /// À faux, seule la valeur chiffrée est affichée, précédée d'une étoile.
  final bool afficherEtoiles;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (afficherEtoiles)
          ...List.generate(5, (index) {
            final pleine = index < note.floor();
            final demie = !pleine && index < note;
            return Icon(
              demie ? Symboles.starHalf : Symboles.star,
              fill: pleine || demie ? 1 : 0,
              size: taille,
              color: pleine || demie ? Couleurs.orange : Couleurs.encrePale,
            );
          })
        else
          Icon(Symboles.star, fill: 1, size: taille, color: Couleurs.orange),
        const SizedBox(width: Espaces.xs),
        Text(
          Formats.note(note),
          style: Typographie.echelle.labelMedium?.copyWith(
            color: Couleurs.encre,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (nbAvis != null) ...[
          const SizedBox(width: Espaces.xs),
          Text(
            '($nbAvis avis)',
            style: Typographie.echelle.bodySmall,
          ),
        ],
      ],
    );
  }
}

/// Coche de vérification affichée à côté du nom d'un vendeur vérifié.
///
/// Le badge récompense des signaux concrets, identité, historique de ventes,
/// taux de réponse, et non le statut juridique : un vendeur informel peut
/// l'obtenir au même titre qu'une boutique enregistrée.
class BadgeVerifie extends StatelessWidget {
  const BadgeVerifie({super.key, this.taille = 16});

  final double taille;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Vendeur vérifié',
      child: Icon(
        Symboles.verified,
        fill: 1,
        size: taille,
        color: Couleurs.orange,
      ),
    );
  }
}

/// Image tirée d'une ressource embarquée ou d'une adresse distante.
///
/// Le catalogue mêle deux provenances : les visuels livrés avec l'application,
/// désignés par un chemin de ressource, et ceux que la base renverra sous
/// forme d'adresse. Les deux ne s'affichent pas avec le même widget, d'où cet
/// aiguillage, invisible pour l'appelant, qui ne manipule qu'une chaîne.
class _ImageDeSource extends StatelessWidget {
  const _ImageDeSource({required this.url, this.hauteurAffichee});

  final String url;

  /// Hauteur à laquelle l'image sera montrée, en points.
  ///
  /// Sert à borner le décodage. Sans elle, Flutter développe le fichier à sa
  /// taille native : une photo de 1200 pixels de côté occupe alors près de six
  /// mégaoctets de mémoire pour être affichée sur cent trente points de haut.
  /// Une grille de quatre vignettes suffit à faire cesser de répondre un
  /// téléphone d'entrée de gamme, ce que le cahier des charges interdit.
  final double? hauteurAffichee;

  /// La photo se pose en fondu sur sa réserve plutôt que de la remplacer d'un
  /// coup : sur une liste qui défile, la substitution brutale donne
  /// l'impression d'un clignotement.
  Widget _fondu(
    BuildContext context,
    Widget enfant,
    int? image,
    bool depuisLeCache,
  ) {
    if (depuisLeCache) return enfant;
    return AnimatedOpacity(
      opacity: image == null ? 0 : 1,
      duration: Mouvement.rapide,
      curve: Mouvement.courbe,
      child: enfant,
    );
  }

  Widget _rien(BuildContext context, Object erreur, StackTrace? trace) =>
      const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    final distante = url.startsWith('http://') || url.startsWith('https://');

    // La consigne est donnée en pixels de l'appareil, non en points : c'est
    // la résolution réelle à laquelle le décodeur doit s'arrêter.
    final densite = MediaQuery.devicePixelRatioOf(context);
    final hauteurCache = hauteurAffichee == null
        ? null
        : (hauteurAffichee! * densite).round();

    if (distante) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        cacheHeight: hauteurCache,
        frameBuilder: _fondu,
        loadingBuilder: (context, enfant, progression) =>
            progression == null ? enfant : const SizedBox.shrink(),
        errorBuilder: _rien,
      );
    }

    return Image.asset(
      url,
      fit: BoxFit.cover,
      cacheHeight: hauteurCache,
      frameBuilder: _fondu,
      errorBuilder: _rien,
    );
  }
}

/// Image d'un produit, avec sa réserve de chargement.
///
/// Tant qu'aucune photo n'est disponible, jeu de démonstration ou réseau
/// indisponible, un aplat discret tient la place, comme sur les maquettes.
class ImageProduit extends StatelessWidget {
  const ImageProduit({
    super.key,
    required this.url,
    this.hauteur,
    this.chaude = false,
    this.signature,
    this.hauteurAffichee,
  });

  final String url;
  final double? hauteur;

  /// Réserve teintée d'orange, utilisée sur la fiche produit.
  final bool chaude;

  /// Identifiant de l'annonce ou de la boutique.
  ///
  /// Faute de photo, la réserve dessine le réseau propre à cet identifiant
  /// plutôt qu'une icône générique : une liste d'annonces sans visuel devient
  /// une mosaïque de figures distinctes au lieu d'une grille de rectangles
  /// vides. Laisser nul retombe sur l'icône.
  final String? signature;

  /// Hauteur réelle d'affichage, lorsqu'elle est imposée par le parent.
  ///
  /// [hauteur] dimensionne l'image ; celle-ci sert uniquement à borner le
  /// décodage. Les deux diffèrent chaque fois qu'un `SizedBox` extérieur
  /// contraint déjà la taille, la vignette d'une boutique, une ligne de
  /// panier, et que [hauteur] reste donc nulle.
  final double? hauteurAffichee;

  @override
  Widget build(BuildContext context) {
    final fond = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: chaude
            ? const [Couleurs.orangePale, Color(0xFFFAF6F1)]
            : const [Couleurs.blancChamp, Couleurs.blancCreux],
      ),
    );

    // Faute de visuel, la place est tenue par le réseau propre à l'annonce,
    // ou par une icône si aucune signature n'a été transmise.
    final reserve = DecoratedBox(
      decoration: fond,
      child: signature == null
          ? const Center(
              child: Icon(
                Symboles.image,
                size: 32,
                color: Couleurs.encreFantome,
              ),
            )
          : MotifReseau(
              graine: MotifReseau.grainePour(signature!),
              densite: 7,
            ),
    );

    return SizedBox(
      height: hauteur,
      width: double.infinity,
      child: url.isEmpty
          ? reserve
          : Stack(
              fit: StackFit.expand,
              children: [
                // Sous une image, le fond reste uni : un logo de boutique est
                // transparent par construction, et le réseau se lirait au
                // travers, comme s'il appartenait à l'enseigne.
                DecoratedBox(decoration: fond),
                _ImageDeSource(
                  url: url,
                  hauteurAffichee: hauteurAffichee ?? hauteur,
                ),
              ],
            ),
    );
  }
}
