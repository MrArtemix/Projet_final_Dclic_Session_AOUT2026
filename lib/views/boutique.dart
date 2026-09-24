import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/favoris_controller.dart';
import '../controllers/localisation_controller.dart';
import '../controllers/produit_controller.dart';
import '../models/boutique.dart';
import '../theme/couleurs.dart';
import '../theme/dimensions.dart';
import '../theme/formes.dart';
import '../theme/profondeur.dart';
import '../theme/symboles.dart';
import '../theme/typographie.dart';
import '../utils/formats.dart';
import '../widgets/communs/boutons.dart';
import '../widgets/communs/etats.dart';
import '../widgets/communs/fond_texture.dart';
import '../widgets/metier/cartes.dart';
import '../widgets/metier/indicateurs.dart';
import 'details_produit.dart';

/// Vitrine d'un vendeur.
///
/// Cet écran porte l'essentiel des signaux de confiance exigés par le cahier
/// des charges, note, nombre de ventes, ancienneté, taux de réponse, badge de
/// vérification. Ce sont eux qui permettent d'évaluer un vendeur informel, que
/// nul statut juridique ne garantit.
class PageBoutique extends StatefulWidget {
  const PageBoutique({super.key, required this.boutique});

  final Boutique boutique;

  @override
  State<PageBoutique> createState() => _PageBoutiqueState();
}

class _PageBoutiqueState extends State<PageBoutique>
    with SingleTickerProviderStateMixin {
  late final TabController _onglets = TabController(length: 3, vsync: this);
  bool _suivie = false;

  Boutique get _boutique => widget.boutique;

  @override
  void dispose() {
    _onglets.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogue = context.watch<ProduitController>();
    final localisation = context.watch<LocalisationController>();

    final produits = catalogue.produitsDeLaBoutique(_boutique.id);
    final distance = localisation.distanceVers(
      _boutique.latitude,
      _boutique.longitude,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FondTexture(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _BarreHaute(titre: 'Info magasin'),
                    _Banniere(boutique: _boutique),
                    _Identite(boutique: _boutique, distanceKm: distance),
                    _Statistiques(boutique: _boutique),
                    Padding(
                      padding: Espaces.ecran,
                      child: _suivie
                          ? BoutonSecondaire(
                              libelle: 'Boutique suivie',
                              icone: Symboles.check,
                              onPressed: () => setState(() => _suivie = false),
                            )
                          : BoutonPrincipal(
                              libelle: 'Suivre la boutique',
                              icone: Symboles.add,
                              onPressed: () => setState(() => _suivie = true),
                            ),
                    ),
                    const SizedBox(height: Espaces.l),
                    TabBar(
                      controller: _onglets,
                      tabs: [
                        Tab(text: 'Produits (${produits.length})'),
                        const Tab(text: 'Avis'),
                        const Tab(text: 'À propos'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _onglets,
            children: [
              _OngletProduits(produits: produits),
              _OngletAvis(boutique: _boutique),
              _OngletAPropos(boutique: _boutique, distanceKm: distance),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarreHaute extends StatelessWidget {
  const _BarreHaute({required this.titre});

  final String titre;

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
              titre,
              textAlign: TextAlign.center,
              style: Typographie.echelle.titleLarge?.copyWith(fontSize: 17),
            ),
          ),
          BoutonRond(
            icone: Symboles.moreVert,
            infobulle: 'Signaler cette boutique',
            onPressed: () => _signaler(context),
          ),
        ],
      ),
    );
  }

  /// Le signalement place la boutique en file de modération sans suppression
  /// automatique, conformément au dossier de conception.
  void _signaler(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Symboles.flag, color: Couleurs.erreur),
              title: const Text('Signaler cette boutique'),
              subtitle: const Text(
                'Un modérateur examinera le signalement. L\'annonce reste '
                'visible entre-temps.',
              ),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Signalement transmis à la modération.'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Symboles.share),
              title: const Text('Partager la boutique'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bandeau haut de la vitrine.
class _Banniere extends StatelessWidget {
  const _Banniere({required this.boutique});

  final Boutique boutique;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      width: double.infinity,
      child: boutique.banniere.isEmpty
          ? const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Couleurs.noir, Couleurs.orangeEncre],
                ),
              ),
            )
          : ImageProduit(url: boutique.banniere, hauteur: 130),
    );
  }
}

/// Logo, nom, spécialité et note.
class _Identite extends StatelessWidget {
  const _Identite({required this.boutique, this.distanceKm});

  final Boutique boutique;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Espaces.l, 0, Espaces.l, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Transform.translate(
            offset: const Offset(0, -34),
            child: Container(
              height: 78,
              width: 78,
              decoration: BoxDecoration(
                color: Couleurs.blancChamp,
                shape: BoxShape.circle,
                border: Border.all(color: Couleurs.blanc, width: 3),
                boxShadow: Profondeur.contact,
              ),
              clipBehavior: Clip.antiAlias,
              child: ImageProduit(
                url: boutique.logo,
                signature: boutique.id,
                hauteurAffichee: 78,
              ),
            ),
          ),
          const SizedBox(width: Espaces.m),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: Espaces.s),
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
                          style: Typographie.echelle.headlineMedium,
                        ),
                      ),
                      if (boutique.verifiee) ...[
                        const SizedBox(width: Espaces.xs),
                        const BadgeVerifie(taille: 17),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  EtiquetteDistance(
                    distanceKm: distanceKm,
                    commune: boutique.categorie,
                    compact: true,
                  ),
                  const SizedBox(height: Espaces.xs),
                  NoteEtoiles(
                    note: boutique.note,
                    nbAvis: boutique.nbAvis,
                    taille: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Produits, abonnés, ventes, les trois chiffres de la maquette.
class _Statistiques extends StatelessWidget {
  const _Statistiques({required this.boutique});

  final Boutique boutique;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Espaces.l, 0, Espaces.l, Espaces.l),
      child: Row(
        children: [
          _Chiffre(
            valeur: Formats.compteurAbrege(boutique.nbProduits),
            libelle: 'Produits',
          ),
          _Chiffre(
            valeur: Formats.compteurAbrege(boutique.nbAbonnes),
            libelle: 'Abonnés',
          ),
          _Chiffre(
            valeur: Formats.compteurAbrege(boutique.nbVentes),
            libelle: 'Ventes',
          ),
        ],
      ),
    );
  }
}

class _Chiffre extends StatelessWidget {
  const _Chiffre({required this.valeur, required this.libelle});

  final String valeur;
  final String libelle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(valeur, style: Typographie.echelle.headlineMedium),
          Text(libelle, style: Typographie.echelle.bodySmall),
        ],
      ),
    );
  }
}

/// Catalogue de la boutique.
class _OngletProduits extends StatelessWidget {
  const _OngletProduits({required this.produits});

  final List<dynamic> produits;

  @override
  Widget build(BuildContext context) {
    if (produits.isEmpty) {
      return const EtatVide(
        icone: Symboles.inventory2,
        titre: 'Catalogue vide',
        message: 'Cette boutique n\'a pas encore publié d\'annonce.',
      );
    }

    final localisation = context.watch<LocalisationController>();
    final favoris = context.watch<FavorisController>();

    return GridView.builder(
      padding: const EdgeInsets.all(Espaces.l),
      itemCount: produits.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: Espaces.m,
        mainAxisSpacing: Espaces.m,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final produit = produits[index];
        return CarteProduit(
          produit: produit,
          distanceKm: localisation.distanceVers(
            produit.latitude as double,
            produit.longitude as double,
          ),
          estFavori: favoris.estFavori(produit.id as String),
          onFavori: () => favoris.basculer(produit.id as String),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DetailsProduit(produit: produit),
            ),
          ),
        );
      },
    );
  }
}

/// Avis laissés sur la boutique.
class _OngletAvis extends StatelessWidget {
  const _OngletAvis({required this.boutique});

  final Boutique boutique;

  @override
  Widget build(BuildContext context) {
    // Le jeu de démonstration ne contient pas encore d'avis rédigés : le
    // résumé chiffré est affiché, la liste viendra du module de réputation.
    return ListView(
      padding: const EdgeInsets.all(Espaces.l),
      children: [
        Container(
          padding: const EdgeInsets.all(Espaces.l),
          decoration: BoxDecoration(
            color: Couleurs.blanc,
            borderRadius: Coupes.carte,
            border: Border.all(color: Couleurs.filet),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Formats.note(boutique.note),
                    style: Typographie.echelle.displayMedium,
                  ),
                  NoteEtoiles(note: boutique.note, taille: 15),
                  const SizedBox(height: Espaces.xs),
                  Text(
                    '${boutique.nbAvis} avis',
                    style: Typographie.echelle.bodySmall,
                  ),
                ],
              ),
              const SizedBox(width: Espaces.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LigneConfiance(
                      icone: Symboles.reply,
                      libelle: 'Taux de réponse',
                      valeur: '${boutique.tauxReponse} %',
                    ),
                    _LigneConfiance(
                      icone: Symboles.localShipping,
                      libelle: 'Ventes réalisées',
                      valeur: Formats.compteurAbrege(boutique.nbVentes),
                    ),
                    _LigneConfiance(
                      icone: Symboles.verified,
                      libelle: 'Vérification',
                      valeur: boutique.verifiee ? 'Vérifiée' : 'En cours',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Espaces.xl),
        const EtatVide(
          icone: Symboles.rateReview,
          titre: 'Avis détaillés à venir',
          message:
              'Un avis ne peut être déposé qu\'après une mise en relation '
              'effective avec le vendeur.',
        ),
      ],
    );
  }
}

class _LigneConfiance extends StatelessWidget {
  const _LigneConfiance({
    required this.icone,
    required this.libelle,
    required this.valeur,
  });

  final IconData icone;
  final String libelle;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Espaces.s),
      child: Row(
        children: [
          Icon(icone, size: 16, color: Couleurs.encrePale),
          const SizedBox(width: Espaces.s),
          Expanded(child: Text(libelle, style: Typographie.echelle.bodySmall)),
          Text(valeur, style: Typographie.echelle.titleSmall),
        ],
      ),
    );
  }
}

/// Présentation et coordonnées.
class _OngletAPropos extends StatelessWidget {
  const _OngletAPropos({required this.boutique, this.distanceKm});

  final Boutique boutique;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Espaces.l),
      children: [
        Text('À propos', style: Typographie.echelle.titleLarge),
        const SizedBox(height: Espaces.s),
        Text(
          boutique.description,
          style: Typographie.echelle.bodyLarge?.copyWith(
            color: Couleurs.encreDouce,
          ),
        ),
        const SizedBox(height: Espaces.xl),
        _LigneContact(icone: Symboles.call, valeur: boutique.telephone),
        _LigneContact(icone: Symboles.place, valeur: boutique.adresse),
        if (distanceKm != null)
          _LigneContact(
            icone: Symboles.directions,
            valeur: 'À ${distanceKm!.toStringAsFixed(1)} km de votre zone',
          ),
      ],
    );
  }
}

class _LigneContact extends StatelessWidget {
  const _LigneContact({required this.icone, required this.valeur});

  final IconData icone;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    if (valeur.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: Espaces.m),
      child: Row(
        children: [
          Icon(icone, size: 18, color: Couleurs.encreDouce),
          const SizedBox(width: Espaces.m),
          Expanded(child: Text(valeur, style: Typographie.echelle.bodyLarge)),
        ],
      ),
    );
  }
}
