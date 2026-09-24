import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/distance.dart';

/// Vitrine d'un vendeur.
///
/// Une boutique regroupe le catalogue, les statistiques et les avis d'un
/// vendeur. Elle est ouverte aux vendeurs formels comme informels : le badge
/// de vérification se gagne sur des signaux concrets, pas sur un statut
/// juridique.
class Boutique {
  const Boutique({
    required this.id,
    required this.idProprietaire,
    required this.nom,
    this.categorie = '',
    this.description = '',
    this.logo = '',
    this.banniere = '',
    this.telephone = '',
    this.adresse = '',
    this.commune = '',
    this.latitude = 0,
    this.longitude = 0,
    this.note = 0,
    this.nbAvis = 0,
    this.nbProduits = 0,
    this.nbAbonnes = 0,
    this.nbVentes = 0,
    this.verifiee = false,
    this.tauxReponse = 0,
    this.dateCreation,
  });

  final String id;
  final String idProprietaire;
  final String nom;

  /// Spécialité affichée sous le nom : « Informatique », « Téléphonie ».
  final String categorie;

  final String description;
  final String logo;
  final String banniere;
  final String telephone;
  final String adresse;
  final String commune;
  final double latitude;
  final double longitude;

  final double note;
  final int nbAvis;
  final int nbProduits;
  final int nbAbonnes;
  final int nbVentes;

  /// Badge de vérification affiché à côté du nom.
  final bool verifiee;

  /// Part des conversations auxquelles le vendeur a répondu, de 0 à 100. Un
  /// des signaux de confiance exigés par le cahier des charges pour évaluer un
  /// vendeur informel.
  final int tauxReponse;

  final DateTime? dateCreation;

  /// Distance en kilomètres jusqu'à la position donnée.
  double distanceDepuis(double latitude, double longitude) =>
      Distance.entre(latitude, longitude, this.latitude, this.longitude);

  factory Boutique.fromFirestore(DocumentSnapshot doc) {
    final donnees = doc.data() as Map<String, dynamic>? ?? {};
    return Boutique(
      id: doc.id,
      idProprietaire: donnees['idProprietaire'] ?? '',
      nom: donnees['nom'] ?? '',
      categorie: donnees['categorie'] ?? '',
      description: donnees['description'] ?? '',
      logo: donnees['logo'] ?? '',
      banniere: donnees['banniere'] ?? '',
      telephone: donnees['telephone'] ?? '',
      adresse: donnees['adresse'] ?? '',
      commune: donnees['commune'] ?? '',
      latitude: (donnees['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (donnees['longitude'] as num?)?.toDouble() ?? 0,
      note: (donnees['note'] as num?)?.toDouble() ?? 0,
      nbAvis: donnees['nbAvis'] ?? 0,
      nbProduits: donnees['nbProduits'] ?? 0,
      nbAbonnes: donnees['nbAbonnes'] ?? 0,
      nbVentes: donnees['nbVentes'] ?? 0,
      verifiee: donnees['verifiee'] ?? false,
      tauxReponse: donnees['tauxReponse'] ?? 0,
      dateCreation: (donnees['dateCreation'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idProprietaire': idProprietaire,
      'nom': nom,
      'categorie': categorie,
      'description': description,
      'logo': logo,
      'banniere': banniere,
      'telephone': telephone,
      'adresse': adresse,
      'commune': commune,
      'latitude': latitude,
      'longitude': longitude,
      'note': note,
      'nbAvis': nbAvis,
      'nbProduits': nbProduits,
      'nbAbonnes': nbAbonnes,
      'nbVentes': nbVentes,
      'verifiee': verifiee,
      'tauxReponse': tauxReponse,
      'dateCreation':
          dateCreation == null ? null : Timestamp.fromDate(dateCreation!),
    };
  }
}
