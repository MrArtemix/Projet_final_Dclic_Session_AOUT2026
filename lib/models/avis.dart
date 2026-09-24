import 'package:cloud_firestore/cloud_firestore.dart';

/// Avis laissé par un acheteur sur un vendeur.
///
/// Règle de gestion du dossier de conception : un avis ne peut être déposé
/// qu'après une mise en relation effective, c'est-à-dire l'existence d'une
/// conversation sur le produit concerné. Cette condition protège le système de
/// réputation des faux avis, condition de confiance envers les vendeurs
/// informels.
class Avis {
  const Avis({
    required this.id,
    required this.idVendeur,
    required this.idAuteur,
    required this.nomAuteur,
    required this.note,
    this.idProduit = '',
    this.commentaire = '',
    this.photoAuteur = '',
    this.date,
  });

  final String id;
  final String idVendeur;
  final String idAuteur;
  final String nomAuteur;
  final String photoAuteur;
  final String idProduit;

  /// Note de 1 à 5.
  final int note;

  final String commentaire;
  final DateTime? date;

  factory Avis.fromFirestore(DocumentSnapshot doc) {
    final donnees = doc.data() as Map<String, dynamic>? ?? {};
    return Avis(
      id: doc.id,
      idVendeur: donnees['idVendeur'] ?? '',
      idAuteur: donnees['idAuteur'] ?? '',
      nomAuteur: donnees['nomAuteur'] ?? '',
      photoAuteur: donnees['photoAuteur'] ?? '',
      idProduit: donnees['idProduit'] ?? '',
      note: donnees['note'] ?? 5,
      commentaire: donnees['commentaire'] ?? '',
      date: (donnees['date'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idVendeur': idVendeur,
      'idAuteur': idAuteur,
      'nomAuteur': nomAuteur,
      'photoAuteur': photoAuteur,
      'idProduit': idProduit,
      'note': note,
      'commentaire': commentaire,
      'date': date == null ? null : Timestamp.fromDate(date!),
    };
  }
}
