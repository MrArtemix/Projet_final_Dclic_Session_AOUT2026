import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/favoris_controller.dart';
import '../controllers/localisation_controller.dart';
import '../controllers/panier_controller.dart';
import '../controllers/produit_controller.dart';
import '../models/categorie.dart';
import '../models/produit.dart';
import '../theme/couleurs.dart';
import '../theme/dimensions.dart';
import '../theme/formes.dart';
import '../theme/profondeur.dart';
import '../theme/symboles.dart';
import '../theme/typographie.dart';
import '../widgets/communs/apparition.dart';
import '../widgets/communs/champs.dart';
import '../widgets/communs/entete_accueil.dart';
import '../widgets/communs/entete_sombre.dart';
import '../widgets/communs/etats.dart';
import '../widgets/communs/fond_texture.dart';
import '../widgets/metier/cartes.dart';
import 'boutique.dart';
import 'choisir_zone.dart';
import 'compte.dart';
import 'details_produit.dart';
import 'panier.dart';
import 'recherche.dart';

/// Accueil de l'application.
///
/// Toute la page est ordonnée par proximité : les produits les plus proches
/// d'abord, puis les boutiques les plus proches. C'est la traduction directe
/// du principe posé au cahier des charges, où la géolocalisation n'est pas un
/// filtre secondaire mais le moteur de découverte.
class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  @override
  void initState() {
    super.initState();
    // Le chargement est demandé après la première image, afin que l'écran
    // s'affiche immédiatement avec ses zones en attente.
    WidgetsBinding.instance.addPostFrameCallback((_) => _charger());
  }

  Future<void> _charger() async {
    final catalogue = context.read<ProduitController>();
    if (catalogue.produits.isEmpty) await catalogue.charger();

    if (!mounted) return;
    final auth = context.read<AuthController>();
    final identifiant = auth.utilisateur?.id ?? '';
    if (identifiant.isNotEmpty) {
      await context.read<FavorisController>().charger(identifiant);
      if (!mounted) return;
      await context.read<PanierController>().associerUtilisateur(identifiant);
    }
  }

  void _ouvrir(Widget ecran) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => ecran));

  @override
  Widget build(BuildContext context) {
    final catalogue = context.watch<ProduitController>();
    final localisation = context.watch<LocalisationController>();
    final panier = context.watch<PanierController>();
    final favoris = context.watch<FavorisController>();

    final latitude = localisation.latitude;
    final longitude = localisation.longitude;

    final proches = catalogue.aProximite(
      latitude: latitude,
      longitude: longitude,
    );
    final boutiques = catalogue.boutiquesProches(
      latitude: latitude,
      longitude: longitude,
      limite: 3,
    );

    return Scaffold(
      // Le fond est noir : c'est lui que l'on aperçoit lorsque la liste rebondit
      // en haut de course, et il prolonge le bloc d'en-tête.
      backgroundColor: Couleurs.nuit,
      body: RefreshIndicator(
        onRefresh: () => catalogue.charger(),
        color: Couleurs.orange,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            EnteteSombre(
              accroche: 'Trouvez près\nde chez vous.',
              zone: localisation.commune?.libelleComplet ?? 'Zone à définir',
              onChangerZone: () =>
                  _ouvrir(const ChoisirZone(remplaceLePrecedent: false)),
              actions: [
                BoutonRondSombre(
                  icone: Symboles.person,
                  infobulle: 'Mon compte',
                  onPressed: () => _ouvrir(const Compte()),
                ),
                const SizedBox(width: Espaces.s),
                BoutonRondSombre(
                  icone: Symboles.shoppingCart,
                  badge: panier.nombreArticles,
                  infobulle: 'Mon panier',
                  onPressed: () => _ouvrir(const Panier()),
                ),
              ],
              contenuBas: BarreRecherche(
                enLectureSeule: true,
                onTap: () => _ouvrir(const Recherche()),
              ),
            ),

            // Le contenu clair remonte sur le noir : c'est ce recouvrement qui
            // fait lire les deux surfaces comme superposées, et non comme
            // simplement juxtaposées.
            FeuilleClaire(
              child: FondTexture(
                vignettage: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: Espaces.xl),
                    if (catalogue.chargement)
                      const _AccueilEnAttente()
                    else ...[
                      Apparition(
                        child: _Raccourcis(
                          onCategories: () => _ouvrir(const Recherche()),
                          onBoutiques: () =>
                              _ouvrir(const Recherche(ongletBoutiques: true)),
                          onPromotions: () =>
                              _ouvrir(const Recherche(promotionsSeules: true)),
                        ),
                      ),

                      if (catalogue.categories.isNotEmpty)
                        Apparition(
                          rang: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const TitreSection(titre: 'Catégories'),
                              _Categories(
                                categories: catalogue.categories,
                                onTap: (categorie) => _ouvrir(
                                  Recherche(idCategorie: categorie.id),
                                ),
                              ),
                            ],
                          ),
                        ),

                      Apparition(
                        rang: 2,
                        child: TitreSection(
                          titre: 'Produits près de chez vous',
                          onVoirTout: () =>
                              _ouvrir(const Recherche(triProximite: true)),
                        ),
                      ),
                      if (proches.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: Espaces.xl),
                          child: EtatVide(
                            icone: Symboles.inventory2,
                            titre: 'Aucune annonce pour l\'instant',
                            message:
                                'Les annonces publiées près de chez vous '
                                's\'afficheront ici.',
                          ),
                        )
                      else
                        _GrilleProduits(
                          produits: proches,
                          section: 'proches',
                          latitude: latitude,
                          longitude: longitude,
                          favoris: favoris,
                          onTap: (produit) => _ouvrir(
                            DetailsProduit(
                              produit: produit,
                              marqueVol: 'proches-${produit.id}',
                            ),
                          ),
                        ),

                      Apparition(
                        rang: 3,
                        child: TitreSection(
                          titre: 'Boutiques partenaires',
                          onVoirTout: () =>
                              _ouvrir(const Recherche(ongletBoutiques: true)),
                        ),
                      ),
                      for (final (rang, boutique) in boutiques.indexed)
                        Apparition(
                          rang: 4 + rang,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              Espaces.l,
                              0,
                              Espaces.l,
                              Espaces.m,
                            ),
                            child: CarteBoutique(
                              boutique: boutique,
                              distanceKm: localisation.distanceVers(
                                boutique.latitude,
                                boutique.longitude,
                              ),
                              onSuivre: () => _signalerSuivi(boutique.nom),
                              onTap: () =>
                                  _ouvrir(PageBoutique(boutique: boutique)),
                            ),
                          ),
                        ),

                      if (catalogue.enPromotion.isNotEmpty) ...[
                        TitreSection(
                          titre: 'Promotions',
                          onVoirTout: () =>
                              _ouvrir(const Recherche(promotionsSeules: true)),
                        ),
                        _GrilleProduits(
                          produits: catalogue.enPromotion.take(4).toList(),
                          section: 'promos',
                          latitude: latitude,
                          longitude: longitude,
                          favoris: favoris,
                          onTap: (produit) => _ouvrir(
                            DetailsProduit(
                              produit: produit,
                              marqueVol: 'promos-${produit.id}',
                            ),
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: Espaces.xxxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _signalerSuivi(String nom) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Vous suivez désormais $nom.')));
  }
}

/// Les trois raccourcis de la maquette : catégories, boutiques, promotions.
class _Raccourcis extends StatelessWidget {
  const _Raccourcis({
    required this.onCategories,
    required this.onBoutiques,
    required this.onPromotions,
  });

  final VoidCallback onCategories;
  final VoidCallback onBoutiques;
  final VoidCallback onPromotions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Espaces.l, Espaces.l, Espaces.l, 0),
      child: Row(
        children: [
          Expanded(
            child: _Raccourci(
              libelle: 'Catégories',
              icone: Symboles.gridView,
              onTap: onCategories,
            ),
          ),
          const SizedBox(width: Espaces.m),
          Expanded(
            child: _Raccourci(
              libelle: 'Boutiques',
              icone: Symboles.storefront,
              onTap: onBoutiques,
            ),
          ),
          const SizedBox(width: Espaces.m),
          Expanded(
            child: _Raccourci(
              libelle: 'Promotions',
              icone: Symboles.localOffer,
              onTap: onPromotions,
              accentue: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _Raccourci extends StatelessWidget {
  const _Raccourci({
    required this.libelle,
    required this.icone,
    required this.onTap,
    this.accentue = false,
  });

  final String libelle;
  final IconData icone;
  final VoidCallback onTap;

  /// Les promotions portent l'orange : elles représentent un gain.
  final bool accentue;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accentue ? Couleurs.orangePale : Couleurs.blanc,
      borderRadius: Coupes.carte,
      child: InkWell(
        onTap: onTap,
        borderRadius: Coupes.carte,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: Espaces.l),
          decoration: BoxDecoration(
            borderRadius: Coupes.carte,
            border: Border.all(
              color: accentue
                  ? Couleurs.orange.withValues(alpha: 0.3)
                  : Couleurs.filet,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icone,
                size: 26,
                color: accentue ? Couleurs.orangeVif : Couleurs.encre,
              ),
              const SizedBox(height: Espaces.s),
              Text(
                libelle,
                style: Typographie.echelle.labelMedium?.copyWith(
                  color: accentue ? Couleurs.orangeVif : Couleurs.encre,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bandeau horizontal des catégories.
class _Categories extends StatelessWidget {
  const _Categories({required this.categories, required this.onTap});

  final List<Categorie> categories;
  final ValueChanged<Categorie> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: Espaces.ecran,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: Espaces.m),
        itemBuilder: (context, index) {
          final categorie = categories[index];
          return SizedBox(
            width: 78,
            child: InkWell(
              onTap: () => onTap(categorie),
              borderRadius: Coupes.puce,
              child: Column(
                children: [
                  Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      color: Couleurs.blanc,
                      borderRadius: Coupes.puce,
                      border: Border.all(color: Couleurs.filet),
                      boxShadow: Profondeur.contact,
                    ),
                    child: Icon(
                      categorie.icone,
                      size: 24,
                      color: Couleurs.encre,
                    ),
                  ),
                  const SizedBox(height: Espaces.xs),
                  Text(
                    categorie.nom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Typographie.echelle.labelSmall?.copyWith(
                      color: Couleurs.encreDouce,
                      letterSpacing: 0,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Grille de deux colonnes d'annonces.
class _GrilleProduits extends StatelessWidget {
  const _GrilleProduits({
    required this.produits,
    required this.favoris,
    required this.onTap,
    required this.section,
    this.latitude,
    this.longitude,
  });

  final List<Produit> produits;
  final FavorisController favoris;
  final ValueChanged<Produit> onTap;

  /// Nom de la section, qui préfixe les marques de vol.
  ///
  /// L'accueil affiche deux grilles, et un même produit peut figurer dans les
  /// deux : sans ce préfixe, deux vignettes porteraient la même marque sur une
  /// seule page, ce que Flutter refuse.
  final String section;

  final double? latitude;
  final double? longitude;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: Espaces.ecran,
      itemCount: produits.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: Espaces.m,
        mainAxisSpacing: Espaces.m,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final produit = produits[index];
        // La grille est repliée dans la page et ne défile pas d'elle-même :
        // ses cartes ne sont donc jamais recyclées, et la cascade ne se
        // rejouera pas sous les doigts du lecteur.
        return Apparition(
          rang: index,
          child: CarteProduit(
            produit: produit,
            distanceKm: (latitude != null && longitude != null)
                ? produit.distanceDepuis(latitude!, longitude!)
                : null,
            estFavori: favoris.estFavori(produit.id),
            marqueVol: '$section-${produit.id}',
            onFavori: () => favoris.basculer(produit.id),
            onTap: () => onTap(produit),
          ),
        );
      },
    );
  }
}

/// Squelette affiché pendant le chargement du catalogue.
///
/// Préféré à un indicateur tournant : la page garde sa structure, ce qui évite
/// un saut de mise en page à l'arrivée des données.
class _AccueilEnAttente extends StatelessWidget {
  const _AccueilEnAttente();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: Espaces.ecran,
      children: [
        const SizedBox(height: Espaces.l),
        Row(
          children: List.generate(
            3,
            (_) => const Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: Espaces.m),
                child: BlocSquelette(hauteur: 84),
              ),
            ),
          ),
        ),
        const SizedBox(height: Espaces.xl),
        const BlocSquelette(hauteur: 22, largeur: 180),
        const SizedBox(height: Espaces.l),
        for (var ligne = 0; ligne < 2; ligne++) ...[
          Row(
            children: List.generate(
              2,
              (_) => const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: Espaces.m),
                  child: BlocSquelette(hauteur: 230),
                ),
              ),
            ),
          ),
          const SizedBox(height: Espaces.m),
        ],
      ],
    );
  }
}
