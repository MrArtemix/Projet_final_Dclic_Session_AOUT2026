import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/favoris_controller.dart';
import '../controllers/localisation_controller.dart';
import '../controllers/produit_controller.dart';
import '../models/produit.dart';
import '../theme/couleurs.dart';
import '../theme/dimensions.dart';
import '../theme/formes.dart';
import '../theme/symboles.dart';
import '../theme/typographie.dart';
import '../utils/formats.dart';
import '../widgets/communs/boutons.dart';
import '../widgets/communs/champs.dart';
import '../widgets/communs/etats.dart';
import '../widgets/communs/fond_texture.dart';
import '../widgets/metier/cartes.dart';
import 'boutique.dart';
import 'details_produit.dart';

/// Recherche et résultats.
///
/// Les filtres restent affichés en permanence au-dessus des résultats et se
/// modifient sans relancer la recherche, comme le demande le dossier de
/// conception. Chaque filtre actif se voit, puce orange, et se retire d'un
/// seul geste.
class Recherche extends StatefulWidget {
  const Recherche({
    super.key,
    this.idCategorie,
    this.promotionsSeules = false,
    this.triProximite = false,
    this.ongletBoutiques = false,
  });

  /// Catégorie présélectionnée, à l'arrivée depuis l'accueil.
  final String? idCategorie;

  /// N'affiche que les annonces en réduction.
  final bool promotionsSeules;

  /// Ouvre directement le tri par proximité.
  final bool triProximite;

  /// Ouvre sur la liste des boutiques plutôt que des produits.
  final bool ongletBoutiques;

  @override
  State<Recherche> createState() => _RechercheState();
}

class _RechercheState extends State<Recherche> {
  final _saisie = TextEditingController();
  late bool _surBoutiques = widget.ongletBoutiques;

  @override
  void initState() {
    super.initState();

    // Les filtres d'arrivée sont posés après la première image : le
    // contrôleur est partagé, le modifier pendant la construction
    // déclencherait une reconstruction en cours de rendu.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catalogue = context.read<ProduitController>();
      var filtres = const FiltresRecherche();

      if (widget.idCategorie != null) {
        filtres = filtres.copieAvec(idCategorie: widget.idCategorie);
      }
      if (widget.triProximite) {
        filtres = filtres.copieAvec(tri: TriResultats.proximite);
      }
      catalogue.appliquerFiltres(filtres);

      if (catalogue.produits.isEmpty) catalogue.charger();
    });
  }

  @override
  void dispose() {
    _saisie.dispose();
    super.dispose();
  }

  ProduitController get _catalogue => context.read<ProduitController>();

  void _majFiltres(FiltresRecherche filtres) =>
      _catalogue.appliquerFiltres(filtres);

  @override
  Widget build(BuildContext context) {
    final catalogue = context.watch<ProduitController>();
    final localisation = context.watch<LocalisationController>();
    final favoris = context.watch<FavorisController>();
    final filtres = catalogue.filtres;

    var resultats = catalogue.resultats(
      latitude: localisation.latitude,
      longitude: localisation.longitude,
    );

    if (widget.promotionsSeules) {
      resultats = resultats
          .where((produit) => produit.pourcentageReduction != null)
          .toList();
    }

    final boutiques = catalogue.boutiquesProches(
      latitude: localisation.latitude,
      longitude: localisation.longitude,
      limite: 50,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FondTexture(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Espaces.s,
                  Espaces.s,
                  Espaces.l,
                  Espaces.m,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Symboles.arrowBack),
                    ),
                    Expanded(
                      child: BarreRecherche(
                        controleur: _saisie,
                        autofocus: !widget.ongletBoutiques &&
                            widget.idCategorie == null,
                        onChange: (texte) =>
                            _majFiltres(filtres.copieAvec(texte: texte)),
                      ),
                    ),
                  ],
                ),
              ),

              _Onglets(
                surBoutiques: _surBoutiques,
                nombreProduits: resultats.length,
                nombreBoutiques: boutiques.length,
                onChange: (valeur) => setState(() => _surBoutiques = valeur),
              ),

              if (!_surBoutiques) ...[
                _BarreFiltres(
                  filtres: filtres,
                  categories: catalogue.categories,
                  onChange: _majFiltres,
                ),
                _LigneResultats(
                  nombre: resultats.length,
                  tri: filtres.tri,
                  aDesFiltres: filtres.aDesFiltres,
                  onTri: (tri) => _majFiltres(filtres.copieAvec(tri: tri)),
                  onReinitialiser: catalogue.reinitialiserFiltres,
                ),
              ],

              Expanded(
                child: _surBoutiques
                    ? _ListeBoutiques(boutiques: boutiques)
                    : _ListeProduits(
                        produits: resultats,
                        favoris: favoris,
                        onReinitialiser: catalogue.reinitialiserFiltres,
                        aDesFiltres: filtres.aDesFiltres,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bascule entre les produits et les boutiques.
class _Onglets extends StatelessWidget {
  const _Onglets({
    required this.surBoutiques,
    required this.nombreProduits,
    required this.nombreBoutiques,
    required this.onChange,
  });

  final bool surBoutiques;
  final int nombreProduits;
  final int nombreBoutiques;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Espaces.l, 0, Espaces.l, Espaces.m),
      child: Row(
        children: [
          _Onglet(
            libelle: 'Produits ($nombreProduits)',
            actif: !surBoutiques,
            onTap: () => onChange(false),
          ),
          const SizedBox(width: Espaces.xl),
          _Onglet(
            libelle: 'Boutiques ($nombreBoutiques)',
            actif: surBoutiques,
            onTap: () => onChange(true),
          ),
        ],
      ),
    );
  }
}

class _Onglet extends StatelessWidget {
  const _Onglet({
    required this.libelle,
    required this.actif,
    required this.onTap,
  });

  final String libelle;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            libelle,
            style: actif
                ? Typographie.echelle.titleSmall
                : Typographie.echelle.labelMedium?.copyWith(
                    color: Couleurs.encrePale,
                  ),
          ),
          const SizedBox(height: Espaces.xs),
          AnimatedContainer(
            duration: Mouvement.rapide,
            height: 2.5,
            width: actif ? 28 : 0,
            decoration: BoxDecoration(
              color: Couleurs.orange,
              borderRadius: Coupes.pastille,
            ),
          ),
        ],
      ),
    );
  }
}

/// Les quatre puces de filtre de la maquette, plus le filtre « gros ».
class _BarreFiltres extends StatelessWidget {
  const _BarreFiltres({
    required this.filtres,
    required this.categories,
    required this.onChange,
  });

  final FiltresRecherche filtres;
  final List<dynamic> categories;
  final ValueChanged<FiltresRecherche> onChange;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Tailles.puce + Espaces.m,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: Espaces.ecran,
        children: [
          PuceFiltre(
            libelle: _libellePrix(),
            active: filtres.prixMinimum != null || filtres.prixMaximum != null,
            onTap: () => _ouvrirPrix(context),
          ),
          const SizedBox(width: Espaces.s),
          PuceFiltre(
            libelle: _libelleCategorie(),
            active: filtres.idCategorie != null,
            onTap: () => _ouvrirCategorie(context),
          ),
          const SizedBox(width: Espaces.s),
          PuceFiltre(
            libelle: filtres.distanceMaximaleKm == null
                ? 'Distance'
                : 'Moins de ${filtres.distanceMaximaleKm!.round()} km',
            active: filtres.distanceMaximaleKm != null,
            onTap: () => _ouvrirDistance(context),
          ),
          const SizedBox(width: Espaces.s),
          PuceFiltre(
            libelle: filtres.etat?.libelle ?? 'État',
            active: filtres.etat != null,
            onTap: () => _ouvrirEtat(context),
          ),
          const SizedBox(width: Espaces.s),
          PuceFiltre(
            libelle: 'Vente en gros',
            avecFleche: false,
            active: filtres.seulementGros,
            onTap: () => onChange(
              filtres.copieAvec(seulementGros: !filtres.seulementGros),
            ),
          ),
          const SizedBox(width: Espaces.s),
          PuceFiltre(
            libelle: 'Troc',
            avecFleche: false,
            active: filtres.typeTransaction == TypeTransaction.troc,
            onTap: () => onChange(
              filtres.typeTransaction == TypeTransaction.troc
                  ? filtres.copieAvec(viderTransaction: true)
                  : filtres.copieAvec(typeTransaction: TypeTransaction.troc),
            ),
          ),
        ],
      ),
    );
  }

  String _libellePrix() {
    if (filtres.prixMinimum == null && filtres.prixMaximum == null) {
      return 'Prix';
    }
    final minimum = filtres.prixMinimum ?? 0;
    final maximum = filtres.prixMaximum;
    return maximum == null
        ? 'Dès ${Formats.prix(minimum)}'
        : '${Formats.prix(minimum)} – ${Formats.prix(maximum)}';
  }

  String _libelleCategorie() {
    if (filtres.idCategorie == null) return 'Catégorie';
    for (final categorie in categories) {
      if (categorie.id == filtres.idCategorie) return categorie.nom as String;
    }
    return 'Catégorie';
  }

  Future<void> _ouvrirPrix(BuildContext context) async {
    var debut = filtres.prixMinimum ?? 0;
    var fin = filtres.prixMaximum ?? 250;

    await _feuille(
      context,
      titre: 'Fourchette de prix',
      onEffacer: () => onChange(filtres.copieAvec(viderPrix: true)),
      contenu: (rafraichir) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RangeSlider(
            values: RangeValues(debut, fin),
            max: 500,
            divisions: 50,
            activeColor: Couleurs.orange,
            inactiveColor: Couleurs.blancCreux,
            labels: RangeLabels(Formats.prix(debut), Formats.prix(fin)),
            onChanged: (valeurs) => rafraichir(() {
              debut = valeurs.start;
              fin = valeurs.end;
            }),
          ),
          const SizedBox(height: Espaces.m),
          BoutonPrincipal(
            libelle: 'Appliquer',
            onPressed: () {
              onChange(
                filtres.copieAvec(prixMinimum: debut, prixMaximum: fin),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _ouvrirCategorie(BuildContext context) async {
    await _feuille(
      context,
      titre: 'Catégorie',
      onEffacer: () => onChange(filtres.copieAvec(viderCategorie: true)),
      contenu: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final categorie in categories)
            ListTile(
              leading: Icon(categorie.icone as IconData, size: 20),
              title: Text(categorie.nom as String),
              trailing: filtres.idCategorie == categorie.id
                  ? const Icon(
                      Symboles.checkCircle,
                      fill: 1,
                      size: 20,
                      color: Couleurs.orange,
                    )
                  : null,
              onTap: () {
                onChange(
                  filtres.copieAvec(idCategorie: categorie.id as String),
                );
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }

  Future<void> _ouvrirDistance(BuildContext context) async {
    const paliers = [2.0, 5.0, 10.0, 25.0, 50.0];

    await _feuille(
      context,
      titre: 'Distance maximale',
      onEffacer: () => onChange(filtres.copieAvec(viderDistance: true)),
      contenu: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final palier in paliers)
            ListTile(
              leading: const Icon(Symboles.place, fill: 1, size: 20, color: Couleurs.orange),
              title: Text('Moins de ${palier.round()} km'),
              trailing: filtres.distanceMaximaleKm == palier
                  ? const Icon(
                      Symboles.checkCircle,
                      fill: 1,
                      size: 20,
                      color: Couleurs.orange,
                    )
                  : null,
              onTap: () {
                onChange(filtres.copieAvec(distanceMaximaleKm: palier));
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }

  Future<void> _ouvrirEtat(BuildContext context) async {
    await _feuille(
      context,
      titre: 'État du produit',
      onEffacer: () => onChange(filtres.copieAvec(viderEtat: true)),
      contenu: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final etat in EtatProduit.values)
            ListTile(
              title: Text(etat.libelle),
              trailing: filtres.etat == etat
                  ? const Icon(
                      Symboles.checkCircle,
                      fill: 1,
                      size: 20,
                      color: Couleurs.orange,
                    )
                  : null,
              onTap: () {
                onChange(filtres.copieAvec(etat: etat));
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }

  /// Feuille remontante commune aux quatre filtres.
  Future<void> _feuille(
    BuildContext context, {
    required String titre,
    required Widget Function(void Function(void Function())) contenu,
    required VoidCallback onEffacer,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, rafraichir) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Espaces.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(titre, style: Typographie.echelle.titleLarge),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        onEffacer();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Effacer'),
                    ),
                  ],
                ),
                const SizedBox(height: Espaces.m),
                Flexible(
                  child: SingleChildScrollView(child: contenu(rafraichir)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Nombre de résultats et choix du tri.
class _LigneResultats extends StatelessWidget {
  const _LigneResultats({
    required this.nombre,
    required this.tri,
    required this.aDesFiltres,
    required this.onTri,
    required this.onReinitialiser,
  });

  final int nombre;
  final TriResultats tri;
  final bool aDesFiltres;
  final ValueChanged<TriResultats> onTri;
  final VoidCallback onReinitialiser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Espaces.l, 0, Espaces.s, Espaces.s),
      child: Row(
        children: [
          Text(
            '$nombre résultat${nombre > 1 ? 's' : ''}',
            style: Typographie.echelle.bodySmall,
          ),
          if (aDesFiltres) ...[
            const SizedBox(width: Espaces.s),
            InkWell(
              onTap: onReinitialiser,
              borderRadius: Coupes.pastille,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Espaces.s,
                  vertical: 2,
                ),
                child: Text(
                  'Tout effacer',
                  style: Typographie.echelle.bodySmall?.copyWith(
                    color: Couleurs.orangeTexte,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          const Spacer(),
          PopupMenuButton<TriResultats>(
            onSelected: onTri,
            position: PopupMenuPosition.under,
            itemBuilder: (context) => [
              for (final valeur in TriResultats.values)
                PopupMenuItem(
                  value: valeur,
                  child: Row(
                    children: [
                      Text(valeur.libelle),
                      if (valeur == tri) ...[
                        const Spacer(),
                        const Icon(
                          Symboles.check,
                          size: 16,
                          color: Couleurs.orange,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Espaces.s),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Trier : ${tri.libelle}',
                    style: Typographie.echelle.bodySmall?.copyWith(
                      color: Couleurs.encre,
                    ),
                  ),
                  const Icon(
                    Symboles.keyboardArrowDown,
                    size: 16,
                    color: Couleurs.encrePale,
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

/// Grille des annonces trouvées.
class _ListeProduits extends StatelessWidget {
  const _ListeProduits({
    required this.produits,
    required this.favoris,
    required this.onReinitialiser,
    required this.aDesFiltres,
  });

  final List<Produit> produits;
  final FavorisController favoris;
  final VoidCallback onReinitialiser;
  final bool aDesFiltres;

  @override
  Widget build(BuildContext context) {
    if (produits.isEmpty) {
      return EtatVide(
        icone: Symboles.searchOff,
        titre: 'Aucun résultat',
        message: aDesFiltres
            ? 'Aucune annonce ne correspond à ces filtres dans votre zone. '
                'Élargissez la distance ou retirez un filtre.'
            : 'Aucune annonce ne correspond à cette recherche. '
                'Essayez un autre mot-clé.',
        libelleAction: aDesFiltres ? 'Effacer les filtres' : null,
        onAction: aDesFiltres ? onReinitialiser : null,
      );
    }

    final localisation = context.watch<LocalisationController>();

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        Espaces.l,
        Espaces.s,
        Espaces.l,
        Espaces.xxl,
      ),
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
            produit.latitude,
            produit.longitude,
          ),
          afficherNote: true,
          estFavori: favoris.estFavori(produit.id),
          onFavori: () => favoris.basculer(produit.id),
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

/// Liste des boutiques, classées par proximité.
class _ListeBoutiques extends StatelessWidget {
  const _ListeBoutiques({required this.boutiques});

  final List<dynamic> boutiques;

  @override
  Widget build(BuildContext context) {
    if (boutiques.isEmpty) {
      return const EtatVide(
        icone: Symboles.storefront,
        titre: 'Aucune boutique',
        message: 'Aucune boutique n\'est encore référencée dans votre zone.',
      );
    }

    final localisation = context.watch<LocalisationController>();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        Espaces.l,
        Espaces.s,
        Espaces.l,
        Espaces.xxl,
      ),
      itemCount: boutiques.length,
      separatorBuilder: (_, _) => const SizedBox(height: Espaces.m),
      itemBuilder: (context, index) {
        final boutique = boutiques[index];
        return CarteBoutique(
          boutique: boutique,
          distanceKm: localisation.distanceVers(
            boutique.latitude as double,
            boutique.longitude as double,
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PageBoutique(boutique: boutique),
            ),
          ),
        );
      },
    );
  }
}
