import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/distance.dart';

/// État d'un produit mis en vente.
///
/// Le cahier des charges impose que les trois états se distinguent
/// visuellement sur chaque annonce : le marché africain du matériel
/// technologique repose autant sur l'occasion et le bradé que sur le neuf.
enum EtatProduit {
  neuf('neuf', 'Neuf'),
  occasion('occasion', 'Occasion'),
  brade('brade', 'Bradé');

  const EtatProduit(this.code, this.libelle);

  final String code;
  final String libelle;

  static EtatProduit depuisCode(String? code) => values.firstWhere(
        (etat) => etat.code == code,
        orElse: () => occasion,
      );
}

/// Formes d'échange acceptées par le vendeur pour une annonce.
enum TypeTransaction {
  vente('vente', 'Vente'),
  troc('troc', 'Troc'),
  lesDeux('les_deux', 'Vente ou troc');

  const TypeTransaction(this.code, this.libelle);

  final String code;
  final String libelle;

  /// Vrai si le vendeur accepte une proposition de troc.
  bool get accepteTroc => this == troc || this == lesDeux;

  /// Vrai si le produit peut être acheté au prix affiché.
  bool get accepteVente => this == vente || this == lesDeux;

  static TypeTransaction depuisCode(String? code) => values.firstWhere(
        (type) => type.code == code,
        orElse: () => vente,
      );
}

/// Cycle de vie d'une annonce.
enum StatutAnnonce {
  active('active'),
  vendue('vendue'),
  desactivee('desactivee'),
  signalee('signalee');

  const StatutAnnonce(this.code);

  final String code;

  static StatutAnnonce depuisCode(String? code) => values.firstWhere(
        (statut) => statut.code == code,
        orElse: () => active,
      );
}

/// Une annonce déposée sur la plateforme.
class Produit {
  const Produit({
    required this.id,
    required this.idVendeur,
    required this.titre,
    required this.prixDetail,
    this.idBoutique = '',
    this.nomBoutique = '',
    this.idCategorie = '',
    this.description = '',
    this.photos = const [],
    this.prixAvant,
    this.prixGros,
    this.seuilGros,
    this.etat = EtatProduit.occasion,
    this.typeTransaction = TypeTransaction.vente,
    this.caracteristiques = const {},
    this.latitude = 0,
    this.longitude = 0,
    this.commune = '',
    this.note = 0,
    this.nbAvis = 0,
    this.statut = StatutAnnonce.active,
    this.datePublication,
  });

  final String id;
  final String idVendeur;
  final String idBoutique;
  final String nomBoutique;
  final String idCategorie;
  final String titre;
  final String description;
  final List<String> photos;

  /// Prix à l'unité.
  final double prixDetail;

  /// Prix affiché barré, lorsqu'une réduction est en cours.
  final double? prixAvant;

  /// Prix unitaire en gros. Renseigné seulement si le vendeur le propose ; le
  /// dossier de conception demande de n'afficher le palier que dans ce cas.
  final double? prixGros;

  /// Quantité à partir de laquelle le prix en gros s'applique.
  final int? seuilGros;

  final EtatProduit etat;
  final TypeTransaction typeTransaction;

  /// Caractéristiques techniques listées sur la fiche produit : marque,
  /// modèle, état, garantie.
  final Map<String, String> caracteristiques;

  final double latitude;
  final double longitude;
  final String commune;
  final double note;
  final int nbAvis;
  final StatutAnnonce statut;
  final DateTime? datePublication;

  /// Vrai lorsque le vendeur a renseigné un palier de vente en gros.
  bool get aUnPalierGros => prixGros != null && seuilGros != null;

  /// Pourcentage de réduction, arrondi, ou `null` s'il n'y en a pas.
  int? get pourcentageReduction {
    if (prixAvant == null || prixAvant! <= prixDetail) return null;
    return (((prixAvant! - prixDetail) / prixAvant!) * 100).round();
  }

  /// Prix unitaire applicable pour la quantité demandée.
  ///
  /// Règle de gestion du dossier de conception : l'ajout au panier bascule
  /// automatiquement sur le tarif de gros dès que le seuil est atteint.
  double prixPour(int quantite) {
    if (palierGrosAtteint(quantite)) return prixGros!;
    return prixDetail;
  }

  /// Vrai si la quantité demandée atteint le seuil de vente en gros.
  bool palierGrosAtteint(int quantite) =>
      aUnPalierGros && quantite >= seuilGros!;

  /// Distance en kilomètres jusqu'à la position donnée.
  ///
  /// Remplace la requête de proximité que PostGIS aurait assurée : le calcul
  /// est fait sur l'appareil, à partir des coordonnées stockées sur l'annonce.
  double distanceDepuis(double latitude, double longitude) =>
      Distance.entre(latitude, longitude, this.latitude, this.longitude);

  factory Produit.fromFirestore(DocumentSnapshot doc) {
    final donnees = doc.data() as Map<String, dynamic>? ?? {};
    return Produit(
      id: doc.id,
      idVendeur: donnees['idVendeur'] ?? '',
      idBoutique: donnees['idBoutique'] ?? '',
      nomBoutique: donnees['nomBoutique'] ?? '',
      idCategorie: donnees['idCategorie'] ?? '',
      titre: donnees['titre'] ?? '',
      description: donnees['description'] ?? '',
      photos: List<String>.from(donnees['photos'] ?? const []),
      prixDetail: (donnees['prixDetail'] as num?)?.toDouble() ?? 0,
      prixAvant: (donnees['prixAvant'] as num?)?.toDouble(),
      prixGros: (donnees['prixGros'] as num?)?.toDouble(),
      seuilGros: donnees['seuilGros'],
      etat: EtatProduit.depuisCode(donnees['etat']),
      typeTransaction: TypeTransaction.depuisCode(donnees['typeTransaction']),
      caracteristiques:
          Map<String, String>.from(donnees['caracteristiques'] ?? const {}),
      latitude: (donnees['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (donnees['longitude'] as num?)?.toDouble() ?? 0,
      commune: donnees['commune'] ?? '',
      note: (donnees['note'] as num?)?.toDouble() ?? 0,
      nbAvis: donnees['nbAvis'] ?? 0,
      statut: StatutAnnonce.depuisCode(donnees['statut']),
      datePublication: (donnees['datePublication'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idVendeur': idVendeur,
      'idBoutique': idBoutique,
      'nomBoutique': nomBoutique,
      'idCategorie': idCategorie,
      'titre': titre,
      'description': description,
      'photos': photos,
      'prixDetail': prixDetail,
      'prixAvant': prixAvant,
      'prixGros': prixGros,
      'seuilGros': seuilGros,
      'etat': etat.code,
      'typeTransaction': typeTransaction.code,
      'caracteristiques': caracteristiques,
      'latitude': latitude,
      'longitude': longitude,
      'commune': commune,
      'note': note,
      'nbAvis': nbAvis,
      'statut': statut.code,
      'datePublication':
          datePublication == null ? null : Timestamp.fromDate(datePublication!),
    };
  }
}
