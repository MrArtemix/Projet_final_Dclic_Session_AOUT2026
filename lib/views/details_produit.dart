import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/favoris_controller.dart';
import '../controllers/localisation_controller.dart';
import '../controllers/panier_controller.dart';
import '../controllers/produit_controller.dart';
import '../models/produit.dart';
import '../theme/couleurs.dart';
import '../theme/dimensions.dart';
import '../theme/formes.dart';
import '../theme/symboles.dart';
import '../theme/profondeur.dart';
import '../theme/typographie.dart';
import '../utils/formats.dart';
import '../widgets/communs/boutons.dart';
import '../widgets/communs/fond_texture.dart';
import '../widgets/metier/cartes.dart';
import '../widgets/metier/indicateurs.dart';
import '../widgets/metier/negociation.dart';
import 'boutique.dart';
import 'chat.dart';
import 'panier.dart';

/// Fiche détaillée d'une annonce.
///
/// Elle réunit tout ce qui permet de décider : le prix et son éventuel palier
/// de gros, l'état du matériel, la distance jusqu'au vendeur, sa réputation,
/// et les trois issues possibles, acheter, négocier, proposer un troc.
class DetailsProduit extends StatefulWidget {
  const DetailsProduit({super.key, required this.produit, this.marqueVol});

  final Produit produit;

  /// Marque de l'image d'où provient l'ouverture, pour que la vignette de la
  /// carte glisse jusqu'à la galerie au lieu d'être remplacée. Voir
  /// [CarteProduit.marqueVol].
  final String? marqueVol;

  @override
  State<DetailsProduit> createState() => _DetailsProduitState();
}

class _DetailsProduitState extends State<DetailsProduit> {
  int _quantite = 1;
  int _photoAffichee = 0;

  Produit get _produit => widget.produit;

  /// Prix unitaire appliqué à la quantité choisie.
  double get _prixUnitaire => _produit.prixPour(_quantite);

  bool get _auTarifGros => _produit.palierGrosAtteint(_quantite);

  void _changerQuantite(int valeur) {
    final ancienTarifGros = _auTarifGros;
    setState(() => _quantite = valeur.clamp(1, 999));

    // Le franchissement du seuil est signalé : sans cela, le changement de
    // prix unitaire pourrait passer pour une erreur d'affichage.
    if (_auTarifGros && !ancienTarifGros) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Tarif de gros appliqué : '
              '${Formats.prix(_produit.prixGros!)} l\'unité à partir de '
              '${_produit.seuilGros} pièces.',
            ),
          ),
        );
    }
  }

  void _ajouterAuPanier() {
    context.read<PanierController>().ajouter(_produit, quantite: _quantite);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$_quantite × ${_produit.titre} ajouté au panier.'),
          action: SnackBarAction(
            label: 'Voir',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const Panier()),
            ),
          ),
        ),
      );
  }

  void _negocier() => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => Chat(produit: _produit)),
      );

  void _proposerTroc() => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => Chat(produit: _produit, ouvrirSurTroc: true),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final favoris = context.watch<FavorisController>();
    final localisation = context.watch<LocalisationController>();
    final catalogue = context.watch<ProduitController>();

    final distance = localisation.distanceVers(
      _produit.latitude,
      _produit.longitude,
    );
    final boutique = catalogue.boutiqueParId(_produit.idBoutique);
    final similaires = catalogue.similaires(_produit);
    final reduction = _produit.pourcentageReduction;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FondTexture(
        ambiance: AmbianceFond.chaude,
        child: SafeArea(
          child: Column(
            children: [
              _BarreHaute(
                estFavori: favoris.estFavori(_produit.id),
                onFavori: () => favoris.basculer(_produit.id),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: Espaces.xl),
                  children: [
                    _Galerie(
                      produit: _produit,
                      index: _photoAffichee,
                      marqueVol: widget.marqueVol,
                      onChange: (index) =>
                          setState(() => _photoAffichee = index),
                    ),

                    Padding(
                      padding: Espaces.ecran,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: Espaces.l),
                          Row(
                            children: [
                              Text(
                                catalogue
                                        .categorieParId(_produit.idCategorie)
                                        ?.nom
                                        .toUpperCase() ??
                                    'MATÉRIEL',
                                style: Typographie.sectionCapitales,
                              ),
                              const SizedBox(width: Espaces.m),
                              BadgeEtat(etat: _produit.etat, compact: true),
                            ],
                          ),
                          const SizedBox(height: Espaces.s),
                          Text(
                            _produit.titre,
                            style: Typographie.echelle.headlineLarge,
                          ),
                          const SizedBox(height: Espaces.m),

                          if (_produit.nbAvis > 0)
                            NoteEtoiles(
                              note: _produit.note,
                              nbAvis: _produit.nbAvis,
                              taille: 16,
                            ),
                          const SizedBox(height: Espaces.m),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                Formats.prix(_prixUnitaire),
                                style: Typographie.prix.copyWith(fontSize: 30),
                              ),
                              const SizedBox(width: Espaces.m),
                              if (_produit.prixAvant != null)
                                Text(
                                  Formats.prix(_produit.prixAvant!),
                                  style: Typographie.prixBarre,
                                ),
                              const SizedBox(width: Espaces.m),
                              if (reduction != null)
                                BadgeReduction(pourcentage: reduction),
                            ],
                          ),
                          const SizedBox(height: Espaces.s),
                          EtiquetteDistance(
                            distanceKm: distance,
                            commune: _produit.commune,
                          ),

                          if (_produit.aUnPalierGros) ...[
                            const SizedBox(height: Espaces.l),
                            _PalierGros(
                              produit: _produit,
                              actif: _auTarifGros,
                            ),
                          ],

                          const SizedBox(height: Espaces.xl),
                          const Divider(),
                          const SizedBox(height: Espaces.l),

                          Text(
                            'Description',
                            style: Typographie.echelle.titleLarge,
                          ),
                          const SizedBox(height: Espaces.s),
                          Text(
                            _produit.description,
                            style: Typographie.echelle.bodyLarge?.copyWith(
                              color: Couleurs.encreDouce,
                            ),
                          ),

                          if (_produit.caracteristiques.isNotEmpty) ...[
                            const SizedBox(height: Espaces.xl),
                            Text(
                              'Caractéristiques',
                              style: Typographie.echelle.titleLarge,
                            ),
                            const SizedBox(height: Espaces.m),
                            for (final ligne
                                in _produit.caracteristiques.entries)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: Espaces.s,
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 120,
                                      child: Text(
                                        ligne.key,
                                        style:
                                            Typographie.echelle.bodyMedium,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        ligne.value,
                                        style: Typographie
                                            .echelle.titleSmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],

                          const SizedBox(height: Espaces.xl),
                          Row(
                            children: [
                              Text(
                                'Quantité',
                                style: Typographie.echelle.titleLarge,
                              ),
                              const Spacer(),
                              SelecteurQuantite(
                                quantite: _quantite,
                                onChange: _changerQuantite,
                              ),
                            ],
                          ),

                          if (_produit.typeTransaction.accepteTroc) ...[
                            const SizedBox(height: Espaces.l),
                            _OptionTroc(onProposer: _proposerTroc),
                          ],

                          const SizedBox(height: Espaces.xl),
                          const Divider(),
                          const SizedBox(height: Espaces.l),
                        ],
                      ),
                    ),

                    if (boutique != null)
                      Padding(
                        padding: Espaces.ecran,
                        child: CarteBoutique(
                          boutique: boutique,
                          distanceKm: localisation.distanceVers(
                            boutique.latitude,
                            boutique.longitude,
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PageBoutique(boutique: boutique),
                            ),
                          ),
                        ),
                      ),

                    if (similaires.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Espaces.l,
                          Espaces.xl,
                          Espaces.l,
                          Espaces.m,
                        ),
                        child: Text(
                          'Produits similaires',
                          style: Typographie.echelle.titleLarge,
                        ),
                      ),
                      SizedBox(
                        height: 268,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: Espaces.ecran,
                          itemCount: similaires.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: Espaces.m),
                          itemBuilder: (context, index) {
                            final autre = similaires[index];
                            return SizedBox(
                              width: 168,
                              child: CarteProduit(
                                produit: autre,
                                distanceKm: localisation.distanceVers(
                                  autre.latitude,
                                  autre.longitude,
                                ),
                                estFavori: favoris.estFavori(autre.id),
                                onFavori: () => favoris.basculer(autre.id),
                                onTap: () => Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute<void>(
                                  builder: (_) => DetailsProduit(produit: autre),
                                )),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              _BarreAction(
                total: _prixUnitaire * _quantite,
                quantite: _quantite,
                achatPossible: _produit.typeTransaction.accepteVente,
                onAjouter: _ajouterAuPanier,
                onNegocier: _negocier,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Retour, titre et mise en favori.
class _BarreHaute extends StatelessWidget {
  const _BarreHaute({required this.estFavori, required this.onFavori});

  final bool estFavori;
  final VoidCallback onFavori;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Espaces.l,
        vertical: Espaces.s,
      ),
      child: Row(
        children: [
          BoutonRond(
            icone: Symboles.arrowBack,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'Détails produit',
              textAlign: TextAlign.center,
              style: Typographie.echelle.titleLarge?.copyWith(fontSize: 17),
            ),
          ),
          BoutonRond(
            icone: Symboles.favorite,
            remplissage: estFavori ? 1 : 0,
            couleurIcone: estFavori ? Couleurs.orangeVif : Couleurs.encre,
            infobulle: estFavori ? 'Retirer des favoris' : 'Mettre en favori',
            onPressed: onFavori,
          ),
        ],
      ),
    );
  }
}

/// Photos de l'annonce, avec ses points d'avancement.
class _Galerie extends StatelessWidget {
  const _Galerie({
    required this.produit,
    required this.index,
    required this.onChange,
    this.marqueVol,
  });

  final Produit produit;
  final int index;
  final ValueChanged<int> onChange;

  /// Marque de la vignette d'origine, pour l'y relier.
  final String? marqueVol;

  /// Enveloppe la galerie dans le vol, si une marque a été transmise.
  ///
  /// Le vol emporte la galerie entière plutôt que sa seule première photo :
  /// c'est la surface, et non l'image, que l'œil suit d'un écran à l'autre.
  Widget _relierAuVol(Widget galerie) =>
      marqueVol == null ? galerie : Hero(tag: marqueVol!, child: galerie);

  @override
  Widget build(BuildContext context) {
    // Le jeu de démonstration ne fournit pas d'images : la galerie conserve
    // alors quatre emplacements, comme la maquette, pour que la mise en page
    // soit représentative.
    final nombre = produit.photos.isEmpty ? 4 : produit.photos.length;

    return Column(
      children: [
        Padding(
          padding: Espaces.ecran,
          child: _relierAuVol(
            ClipRRect(
              borderRadius: Coupes.feuille,
              child: SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: nombre,
                  onPageChanged: onChange,
                  itemBuilder: (context, position) => ImageProduit(
                    url: position < produit.photos.length
                        ? produit.photos[position]
                        : '',
                    chaude: true,
                    hauteurAffichee: 300,
                    // La première vue porte la signature nue du produit,
                    // celle-là même que dessine la vignette de la carte :
                    // pendant le vol, la figure doit grandir, pas changer.
                    signature: position == 0
                        ? produit.id
                        : '${produit.id}-$position',
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Espaces.m),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(nombre, (position) {
            final actif = position == index;
            return AnimatedContainer(
              duration: Mouvement.rapide,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: actif ? 18 : 6,
              decoration: BoxDecoration(
                color: actif ? Couleurs.encre : Couleurs.blancCreux,
                borderRadius: Coupes.pastille,
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Palier de vente en gros.
///
/// Le dossier de conception impose de n'afficher ce bloc que si le vendeur a
/// renseigné un prix de gros et son seuil.
class _PalierGros extends StatelessWidget {
  const _PalierGros({required this.produit, required this.actif});

  final Produit produit;
  final bool actif;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Espaces.l),
      decoration: BoxDecoration(
        color: actif ? Couleurs.orangePale : Couleurs.blancChamp,
        borderRadius: Coupes.puce,
        border: Border.all(
          color: actif ? Couleurs.orange : Couleurs.filet,
          width: actif ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Symboles.inventory2,
            size: 20,
            color: actif ? Couleurs.orangeVif : Couleurs.encreDouce,
          ),
          const SizedBox(width: Espaces.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tarif en gros',
                  style: Typographie.echelle.titleSmall?.copyWith(
                    color: actif ? Couleurs.orangeVif : Couleurs.encre,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${Formats.prix(produit.prixGros!)} l\'unité à partir de '
                  '${produit.seuilGros} pièces',
                  style: Typographie.echelle.bodySmall,
                ),
              ],
            ),
          ),
          if (actif)
            const Icon(
              Symboles.checkCircle,
              fill: 1,
              size: 20,
              color: Couleurs.orangeVif,
            ),
        ],
      ),
    );
  }
}

/// Invitation à proposer un troc, lorsque le vendeur l'accepte.
class _OptionTroc extends StatelessWidget {
  const _OptionTroc({required this.onProposer});

  final VoidCallback onProposer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Espaces.l),
      decoration: BoxDecoration(
        color: Couleurs.blancChamp,
        borderRadius: Coupes.puce,
        border: Border.all(color: Couleurs.filet),
      ),
      child: Row(
        children: [
          const Icon(
            Symboles.swapHoriz,
            size: 22,
            color: Couleurs.encre,
          ),
          const SizedBox(width: Espaces.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Troc accepté', style: Typographie.echelle.titleSmall),
                const SizedBox(height: 2),
                Text(
                  'Proposez un matériel en échange, avec ou sans complément.',
                  style: Typographie.echelle.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: Espaces.s),
          TextButton(onPressed: onProposer, child: const Text('Proposer')),
        ],
      ),
    );
  }
}

/// Barre basse : total, négociation et ajout au panier.
class _BarreAction extends StatelessWidget {
  const _BarreAction({
    required this.total,
    required this.quantite,
    required this.achatPossible,
    required this.onAjouter,
    required this.onNegocier,
  });

  final double total;
  final int quantite;

  /// Faux pour une annonce proposée uniquement au troc : seule la discussion
  /// reste ouverte.
  final bool achatPossible;

  final VoidCallback onAjouter;
  final VoidCallback onNegocier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Espaces.l,
        Espaces.m,
        Espaces.l,
        Espaces.m,
      ),
      decoration: const BoxDecoration(
        color: Couleurs.blanc,
        boxShadow: Profondeur.barre,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total', style: Typographie.echelle.bodySmall),
              _MontantAnime(montant: total),
            ],
          ),
          const SizedBox(width: Espaces.m),
          BoutonRond(
            icone: Symboles.forum,
            infobulle: 'Négocier le prix',
            onPressed: onNegocier,
          ),
          const SizedBox(width: Espaces.s),
          Expanded(
            child: achatPossible
                ? BoutonPrincipal(
                    libelle: 'Ajouter au panier',
                    onPressed: onAjouter,
                  )
                : BoutonPrincipal(
                    libelle: 'Proposer un troc',
                    icone: Symboles.swapHoriz,
                    onPressed: onNegocier,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Montant qui se renouvelle en glissant, plutôt qu'en se substituant.
///
/// Le total est la seule ligne de l'écran que l'utilisateur surveille pendant
/// qu'il modifie son panier. Remplacé sans transition, le changement peut
/// passer inaperçu, et l'on touche une seconde fois le bouton, croyant avoir
/// manqué son geste. Le chiffre monte donc d'un cran, comme une roue de
/// compteur.
class _MontantAnime extends StatelessWidget {
  const _MontantAnime({required this.montant});

  final double montant;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Mouvement.rapide,
      switchInCurve: Mouvement.courbe,
      transitionBuilder: (enfant, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.4),
            end: Offset.zero,
          ).animate(animation),
          child: enfant,
        ),
      ),
      child: Text(
        Formats.prix(montant),
        key: ValueKey(montant),
        style: Typographie.prixCarte,
      ),
    );
  }
}
