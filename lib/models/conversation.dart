import 'package:cloud_firestore/cloud_firestore.dart';

/// Fil de négociation entre un acheteur et un vendeur.
///
/// Une conversation est toujours rattachée à un produit précis : c'est ce
/// rattachement qui permet à la discussion de porter une négociation de prix
/// plutôt qu'un échange général, et qui autorise ensuite le dépôt d'un avis.
class Conversation {
  const Conversation({
    required this.id,
    required this.idProduit,
    required this.idAcheteur,
    required this.idVendeur,
    this.titreProduit = '',
    this.photoProduit = '',
    this.prixProduit = 0,
    this.nomInterlocuteur = '',
    this.photoInterlocuteur = '',
    this.dernierMessage = '',
    this.horodatage,
    this.nbNonLus = 0,
    this.vendeurEnLigne = false,
  });

  final String id;
  final String idProduit;
  final String idAcheteur;
  final String idVendeur;

  // Informations du produit recopiées sur la conversation. Cette duplication
  // est volontaire : elle évite une lecture supplémentaire par conversation à
  // l'affichage de la liste, ce qui compte sur un réseau mobile instable.
  final String titreProduit;
  final String photoProduit;
  final double prixProduit;

  final String nomInterlocuteur;
  final String photoInterlocuteur;
  final String dernierMessage;
  final DateTime? horodatage;
  final int nbNonLus;
  final bool vendeurEnLigne;

  /// Identifiant de l'autre participant, vu depuis l'utilisateur donné.
  String interlocuteurDe(String idUtilisateur) =>
      idUtilisateur == idAcheteur ? idVendeur : idAcheteur;

  factory Conversation.fromFirestore(DocumentSnapshot doc) {
    final donnees = doc.data() as Map<String, dynamic>? ?? {};
    return Conversation(
      id: doc.id,
      idProduit: donnees['idProduit'] ?? '',
      idAcheteur: donnees['idAcheteur'] ?? '',
      idVendeur: donnees['idVendeur'] ?? '',
      titreProduit: donnees['titreProduit'] ?? '',
      photoProduit: donnees['photoProduit'] ?? '',
      prixProduit: (donnees['prixProduit'] as num?)?.toDouble() ?? 0,
      nomInterlocuteur: donnees['nomInterlocuteur'] ?? '',
      photoInterlocuteur: donnees['photoInterlocuteur'] ?? '',
      dernierMessage: donnees['dernierMessage'] ?? '',
      horodatage: (donnees['horodatage'] as Timestamp?)?.toDate(),
      nbNonLus: donnees['nbNonLus'] ?? 0,
      vendeurEnLigne: donnees['vendeurEnLigne'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idProduit': idProduit,
      'idAcheteur': idAcheteur,
      'idVendeur': idVendeur,
      'titreProduit': titreProduit,
      'photoProduit': photoProduit,
      'prixProduit': prixProduit,
      'nomInterlocuteur': nomInterlocuteur,
      'photoInterlocuteur': photoInterlocuteur,
      'dernierMessage': dernierMessage,
      'horodatage':
          horodatage == null ? Timestamp.now() : Timestamp.fromDate(horodatage!),
      'nbNonLus': nbNonLus,
      'vendeurEnLigne': vendeurEnLigne,
    };
  }
}
