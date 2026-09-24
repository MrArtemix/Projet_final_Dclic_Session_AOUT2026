import 'package:cloud_firestore/cloud_firestore.dart';

/// Nature du compte, déclarée à l'inscription.
///
/// Le cahier des charges réunit sur une même plateforme des particuliers et
/// des entreprises. Le type conditionne certains affichages, notamment les
/// paliers de prix en gros, mais ne restreint aucun accès.
enum TypeCompte {
  particulier('particulier', 'Particulier'),
  entreprise('entreprise', 'Entreprise');

  const TypeCompte(this.code, this.libelle);

  /// Valeur stockée dans Firestore.
  final String code;

  /// Valeur affichée à l'écran.
  final String libelle;

  static TypeCompte depuisCode(String? code) => values.firstWhere(
        (type) => type.code == code,
        orElse: () => particulier,
      );
}

/// Statut déclaré par un vendeur.
///
/// Point central du projet : le statut informel est déclaratif et ne bloque
/// **aucun** accès. Un réparateur de quartier sans registre de commerce dépose
/// une annonce exactement comme une boutique enregistrée. Cette règle est
/// vérifiée par les tests du parcours d'inscription.
enum StatutVendeur {
  formel('formel', 'Vendeur formel'),
  informel('informel', 'Vendeur informel'),

  /// Utilisateur qui n'a pas encore vendu : il achète uniquement.
  aucun('aucun', 'Acheteur');

  const StatutVendeur(this.code, this.libelle);

  final String code;
  final String libelle;

  static StatutVendeur depuisCode(String? code) => values.firstWhere(
        (statut) => statut.code == code,
        orElse: () => aucun,
      );
}

/// Un utilisateur de Mekano Afrika.
///
/// Un même compte peut acheter, vendre et proposer un troc : les rôles ne sont
/// pas cloisonnés, conformément au dossier de conception. La position retenue
/// est soit celle du GPS, soit celle de la commune choisie manuellement
/// lorsque la localisation a été refusée.
class Utilisateur {
  const Utilisateur({
    required this.id,
    required this.nom,
    required this.contact,
    this.photo = '',
    this.typeCompte = TypeCompte.particulier,
    this.statutVendeur = StatutVendeur.aucun,
    this.latitude,
    this.longitude,
    this.commune = '',
    this.pays = 'Côte d\'Ivoire',
    this.verifie = false,
    this.note = 0,
    this.nbCommandes = 0,
    this.dateCreation,
  });

  /// Identifiant du compte, aligné sur celui de Firebase Authentication.
  final String id;

  final String nom;

  /// Adresse électronique ou numéro de téléphone, selon le mode d'inscription.
  final String contact;

  final String photo;
  final TypeCompte typeCompte;
  final StatutVendeur statutVendeur;

  /// Dernière position connue. Nulle tant qu'aucune zone n'a été choisie.
  final double? latitude;
  final double? longitude;

  /// Commune de résidence, renseignée par le GPS ou choisie dans la liste.
  final String commune;

  final String pays;

  /// Badge de vérification, attribué indépendamment du statut formel ou
  /// informel du vendeur.
  final bool verifie;

  final double note;
  final int nbCommandes;
  final DateTime? dateCreation;

  /// Vrai lorsque l'utilisateur dispose d'une position exploitable pour trier
  /// les annonces par proximité.
  bool get aUnePosition => latitude != null && longitude != null;

  factory Utilisateur.fromFirestore(DocumentSnapshot doc) {
    final donnees = doc.data() as Map<String, dynamic>? ?? {};
    return Utilisateur(
      id: doc.id,
      nom: donnees['nom'] ?? '',
      contact: donnees['contact'] ?? '',
      photo: donnees['photo'] ?? '',
      typeCompte: TypeCompte.depuisCode(donnees['typeCompte']),
      statutVendeur: StatutVendeur.depuisCode(donnees['statutVendeur']),
      latitude: (donnees['latitude'] as num?)?.toDouble(),
      longitude: (donnees['longitude'] as num?)?.toDouble(),
      commune: donnees['commune'] ?? '',
      pays: donnees['pays'] ?? 'Côte d\'Ivoire',
      verifie: donnees['verifie'] ?? false,
      note: (donnees['note'] as num?)?.toDouble() ?? 0,
      nbCommandes: donnees['nbCommandes'] ?? 0,
      dateCreation: (donnees['dateCreation'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'contact': contact,
      'photo': photo,
      'typeCompte': typeCompte.code,
      'statutVendeur': statutVendeur.code,
      'latitude': latitude,
      'longitude': longitude,
      'commune': commune,
      'pays': pays,
      'verifie': verifie,
      'note': note,
      'nbCommandes': nbCommandes,
      'dateCreation':
          dateCreation == null ? null : Timestamp.fromDate(dateCreation!),
    };
  }

  Utilisateur copieAvec({
    String? nom,
    String? contact,
    String? photo,
    TypeCompte? typeCompte,
    StatutVendeur? statutVendeur,
    double? latitude,
    double? longitude,
    String? commune,
    bool? verifie,
  }) {
    return Utilisateur(
      id: id,
      nom: nom ?? this.nom,
      contact: contact ?? this.contact,
      photo: photo ?? this.photo,
      typeCompte: typeCompte ?? this.typeCompte,
      statutVendeur: statutVendeur ?? this.statutVendeur,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      commune: commune ?? this.commune,
      pays: pays,
      verifie: verifie ?? this.verifie,
      note: note,
      nbCommandes: nbCommandes,
      dateCreation: dateCreation,
    );
  }
}
