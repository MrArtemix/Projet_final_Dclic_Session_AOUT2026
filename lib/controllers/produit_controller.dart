import 'package:flutter/foundation.dart';

import '../data/depot_catalogue.dart';
import '../donnees/jeu_demonstration.dart';
import '../models/boutique.dart';
import '../models/categorie.dart';
import '../models/produit.dart';

/// Critère de classement des résultats.
enum TriResultats {
  pertinence('Pertinence'),
  proximite('Proximité'),
  prixCroissant('Prix croissant'),
  prixDecroissant('Prix décroissant'),
  note('Meilleures notes');

  const TriResultats(this.libelle);

  final String libelle;
}

/// Filtres combinables de la recherche.
///
/// Le dossier de conception demande que les filtres restent visibles et
/// modifiables sans réinitialiser la recherche : ils sont donc conservés dans
/// un objet immuable, remplacé champ par champ à chaque ajustement.
@immutable
class FiltresRecherche {
  const FiltresRecherche({
    this.texte = '',
    this.idCategorie,
    this.prixMinimum,
    this.prixMaximum,
    this.distanceMaximaleKm,
    this.etat,
    this.typeTransaction,
    this.seulementGros = false,
    this.tri = TriResultats.pertinence,
  });

  final String texte;
  final String? idCategorie;
  final double? prixMinimum;
  final double? prixMaximum;
  final double? distanceMaximaleKm;
  final EtatProduit? etat;
  final TypeTransaction? typeTransaction;

  /// Ne retient que les annonces proposant un palier de vente en gros, le
  /// besoin d'une entreprise qui s'approvisionne en volume.
  final bool seulementGros;

  final TriResultats tri;

  /// Nombre de filtres actifs, affiché sur l'écran de résultats.
  int get nombreActifs => [
        idCategorie != null,
        prixMinimum != null || prixMaximum != null,
        distanceMaximaleKm != null,
        etat != null,
        typeTransaction != null,
        seulementGros,
      ].where((actif) => actif).length;

  bool get aDesFiltres => nombreActifs > 0;

  FiltresRecherche copieAvec({
    String? texte,
    String? idCategorie,
    double? prixMinimum,
    double? prixMaximum,
    double? distanceMaximaleKm,
    EtatProduit? etat,
    TypeTransaction? typeTransaction,
    bool? seulementGros,
    TriResultats? tri,
    bool viderCategorie = false,
    bool viderPrix = false,
    bool viderDistance = false,
    bool viderEtat = false,
    bool viderTransaction = false,
  }) {
    return FiltresRecherche(
      texte: texte ?? this.texte,
      idCategorie: viderCategorie ? null : (idCategorie ?? this.idCategorie),
      prixMinimum: viderPrix ? null : (prixMinimum ?? this.prixMinimum),
      prixMaximum: viderPrix ? null : (prixMaximum ?? this.prixMaximum),
      distanceMaximaleKm: viderDistance
          ? null
          : (distanceMaximaleKm ?? this.distanceMaximaleKm),
      etat: viderEtat ? null : (etat ?? this.etat),
      typeTransaction:
          viderTransaction ? null : (typeTransaction ?? this.typeTransaction),
      seulementGros: seulementGros ?? this.seulementGros,
      tri: tri ?? this.tri,
    );
  }
}

/// Catalogue : chargement, recherche, filtres et tri.
///
/// Les données proviennent de Firestore lorsqu'il est disponible, du jeu de
/// démonstration sinon. Le filtrage et le tri s'exécutent sur l'appareil : le
/// catalogue d'une version initiale tient en mémoire, et cela évite autant de
/// requêtes réseau, ce que le cahier des charges réclame explicitement pour
/// les connexions instables.
class ProduitController extends ChangeNotifier {
  ProduitController({DepotCatalogue depot = const DepotCatalogue()})
      : _depot = depot;

  /// Accès aux données, reçu à la construction : le contrôleur ne connaît ni
  /// collection ni requête, seulement des objets du domaine.
  final DepotCatalogue _depot;

  List<Produit> _produits = [];
  List<Boutique> _boutiques = [];
  List<Categorie> _categories = [];

  bool _chargement = false;
  String _erreur = '';
  FiltresRecherche _filtres = const FiltresRecherche();

  List<Produit> get produits => List.unmodifiable(_produits);
  List<Boutique> get boutiques => List.unmodifiable(_boutiques);
  List<Categorie> get categories => List.unmodifiable(_categories);

  bool get chargement => _chargement;
  String get erreur => _erreur;
  FiltresRecherche get filtres => _filtres;

  /// Charge le catalogue.
  Future<void> charger() async {
    _chargement = true;
    _erreur = '';
    notifyListeners();

    if (_depot.disponible) {
      final chargee = await _chargerDepuisLaBase();
      if (!chargee) _chargerDepuisJeuLocal();
    } else {
      _chargerDepuisJeuLocal();
    }

    _chargement = false;
    notifyListeners();
  }

  /// Vrai lorsque la base est joignable : l'écran de compte s'en sert pour
  /// proposer, ou non, l'amorçage du jeu de démonstration.
  bool get baseDisponible => _depot.disponible;

  /// Écrit le jeu de démonstration dans la base, puis recharge le catalogue.
  Future<bool> amorcerDonneesDemonstration() async {
    final ecrit = await _depot.amorcerDonneesDemonstration();
    if (ecrit) await charger();
    return ecrit;
  }

  Future<bool> _chargerDepuisLaBase() async {
    try {
      final contenu = await _depot.lire();

      // Une base encore vide n'est pas une erreur : le jeu local prend le
      // relais, et l'amorçage pourra être lancé depuis l'écran de compte.
      if (contenu.estVide) return false;

      _produits = contenu.produits;
      _boutiques = contenu.boutiques;
      _categories = contenu.categories;
      return true;
    } catch (_) {
      _erreur = 'Catalogue distant indisponible, données locales affichées.';
      return false;
    }
  }

  void _chargerDepuisJeuLocal() {
    _produits = List.of(JeuDemonstration.produits);
    _boutiques = List.of(JeuDemonstration.boutiques);
    _categories = List.of(JeuDemonstration.categories);
  }

  // --- Filtres --------------------------------------------------------------

  void appliquerFiltres(FiltresRecherche filtres) {
    _filtres = filtres;
    notifyListeners();
  }

  void rechercher(String texte) =>
      appliquerFiltres(_filtres.copieAvec(texte: texte));

  void trier(TriResultats tri) => appliquerFiltres(_filtres.copieAvec(tri: tri));

  void reinitialiserFiltres() {
    // Le texte saisi est conservé : seuls les filtres sont remis à zéro.
    _filtres = FiltresRecherche(texte: _filtres.texte, tri: _filtres.tri);
    notifyListeners();
  }

  // --- Lectures -------------------------------------------------------------

  /// Résultats filtrés puis triés, pour une position donnée.
  ///
  /// [latitude] et [longitude] sont nulles tant qu'aucune zone n'est connue :
  /// le filtre de distance et le tri par proximité sont alors sans effet,
  /// mais la recherche continue de fonctionner.
  List<Produit> resultats({double? latitude, double? longitude}) {
    final requete = _filtres.texte.trim().toLowerCase();

    var liste = _produits.where((produit) {
      if (produit.statut != StatutAnnonce.active) return false;

      if (requete.isNotEmpty) {
        final correspond = produit.titre.toLowerCase().contains(requete) ||
            produit.description.toLowerCase().contains(requete) ||
            produit.nomBoutique.toLowerCase().contains(requete);
        if (!correspond) return false;
      }

      if (_filtres.idCategorie != null &&
          produit.idCategorie != _filtres.idCategorie) {
        return false;
      }
      if (_filtres.prixMinimum != null &&
          produit.prixDetail < _filtres.prixMinimum!) {
        return false;
      }
      if (_filtres.prixMaximum != null &&
          produit.prixDetail > _filtres.prixMaximum!) {
        return false;
      }
      if (_filtres.etat != null && produit.etat != _filtres.etat) return false;

      if (_filtres.typeTransaction != null) {
        final voulu = _filtres.typeTransaction!;
        final accepte = voulu == TypeTransaction.troc
            ? produit.typeTransaction.accepteTroc
            : produit.typeTransaction.accepteVente;
        if (!accepte) return false;
      }

      if (_filtres.seulementGros && !produit.aUnPalierGros) return false;

      if (_filtres.distanceMaximaleKm != null &&
          latitude != null &&
          longitude != null) {
        if (produit.distanceDepuis(latitude, longitude) >
            _filtres.distanceMaximaleKm!) {
          return false;
        }
      }

      return true;
    }).toList();

    liste = _appliquerTri(liste, latitude: latitude, longitude: longitude);
    return liste;
  }

  List<Produit> _appliquerTri(
    List<Produit> liste, {
    double? latitude,
    double? longitude,
  }) {
    final aUnePosition = latitude != null && longitude != null;

    switch (_filtres.tri) {
      case TriResultats.prixCroissant:
        liste.sort((a, b) => a.prixDetail.compareTo(b.prixDetail));
      case TriResultats.prixDecroissant:
        liste.sort((a, b) => b.prixDetail.compareTo(a.prixDetail));
      case TriResultats.note:
        liste.sort((a, b) => b.note.compareTo(a.note));
      case TriResultats.proximite:
        if (aUnePosition) {
          liste.sort((a, b) => a
              .distanceDepuis(latitude, longitude)
              .compareTo(b.distanceDepuis(latitude, longitude)));
        }
      case TriResultats.pertinence:
        // À défaut de moteur de recherche dédié, la pertinence combine la
        // proximité et la note : c'est ce que le cahier des charges attend
        // d'un affichage par défaut, où le proche prime sans écarter le reste.
        if (aUnePosition) {
          liste.sort((a, b) {
            final scoreA = _score(a, latitude, longitude);
            final scoreB = _score(b, latitude, longitude);
            return scoreB.compareTo(scoreA);
          });
        } else {
          liste.sort((a, b) => b.note.compareTo(a.note));
        }
    }
    return liste;
  }

  /// Score de pertinence : la note pèse sur cinq points, la proximité en
  /// retire d'autant plus que le vendeur est loin.
  double _score(Produit produit, double latitude, double longitude) {
    final distance = produit.distanceDepuis(latitude, longitude);
    final penaliteDistance = distance / 10;
    return produit.note - penaliteDistance;
  }

  /// Annonces les plus proches, pour la section d'accueil.
  List<Produit> aProximite({
    double? latitude,
    double? longitude,
    int limite = 6,
  }) {
    final liste = _produits
        .where((produit) => produit.statut == StatutAnnonce.active)
        .toList();

    if (latitude != null && longitude != null) {
      liste.sort((a, b) => a
          .distanceDepuis(latitude, longitude)
          .compareTo(b.distanceDepuis(latitude, longitude)));
    }
    return liste.take(limite).toList();
  }

  /// Annonces en promotion, pour le raccourci du même nom.
  List<Produit> get enPromotion => _produits
      .where((produit) => produit.pourcentageReduction != null)
      .toList();

  /// Boutiques classées par proximité.
  List<Boutique> boutiquesProches({
    double? latitude,
    double? longitude,
    int limite = 4,
  }) {
    final liste = List.of(_boutiques);
    if (latitude != null && longitude != null) {
      liste.sort((a, b) => a
          .distanceDepuis(latitude, longitude)
          .compareTo(b.distanceDepuis(latitude, longitude)));
    }
    return liste.take(limite).toList();
  }

  Produit? produitParId(String id) {
    for (final produit in _produits) {
      if (produit.id == id) return produit;
    }
    return null;
  }

  Boutique? boutiqueParId(String id) {
    for (final boutique in _boutiques) {
      if (boutique.id == id) return boutique;
    }
    return null;
  }

  Categorie? categorieParId(String id) {
    for (final categorie in _categories) {
      if (categorie.id == id) return categorie;
    }
    return null;
  }

  /// Catalogue d'une boutique.
  List<Produit> produitsDeLaBoutique(String idBoutique) => _produits
      .where((produit) => produit.idBoutique == idBoutique)
      .toList();

  /// Annonces voisines d'un produit, pour la section « Produits similaires ».
  List<Produit> similaires(Produit produit, {int limite = 4}) => _produits
      .where((autre) =>
          autre.id != produit.id && autre.idCategorie == produit.idCategorie)
      .take(limite)
      .toList();
}
