import 'package:cloud_firestore/cloud_firestore.dart';

/// Nature d'un message échangé dans une conversation.
enum TypeMessage {
  texte('texte'),

  /// Proposition de prix. Le dossier de conception insiste sur ce point : une
  /// offre n'est pas un message texte contenant un montant, mais un objet
  /// distinct doté de son propre statut, ce qui permet de suivre la
  /// négociation indépendamment du fil de discussion.
  offre('offre'),

  /// Message émis par l'application : produit vendu, offre expirée.
  systeme('systeme');

  const TypeMessage(this.code);

  final String code;

  static TypeMessage depuisCode(String? code) => values.firstWhere(
        (type) => type.code == code,
        orElse: () => texte,
      );
}

/// Suivi d'une proposition de prix.
enum StatutOffre {
  attente('attente', 'En attente'),
  acceptee('acceptee', 'Acceptée'),
  refusee('refusee', 'Refusée'),

  /// Une offre laissée sans réponse au-delà du délai est marquée expirée, sans
  /// interrompre la conversation.
  expiree('expiree', 'Expirée');

  const StatutOffre(this.code, this.libelle);

  final String code;
  final String libelle;

  /// Vrai tant que l'offre peut encore être acceptée, refusée ou contrée.
  bool get estOuverte => this == attente;

  static StatutOffre depuisCode(String? code) => values.firstWhere(
        (statut) => statut.code == code,
        orElse: () => attente,
      );
}

/// Délai au-delà duquel une offre sans réponse est considérée comme expirée.
const Duration delaiExpirationOffre = Duration(hours: 48);

/// Un message d'une conversation de négociation.
class Message {
  const Message({
    required this.id,
    required this.idAuteur,
    required this.contenu,
    this.type = TypeMessage.texte,
    this.montantPropose,
    this.statutOffre = StatutOffre.attente,
    this.horodatage,
  });

  final String id;
  final String idAuteur;

  /// Texte du message. Pour une offre, il porte un éventuel commentaire
  /// accompagnant la proposition.
  final String contenu;

  final TypeMessage type;

  /// Montant proposé. Renseigné uniquement pour un message de type offre.
  final double? montantPropose;

  final StatutOffre statutOffre;
  final DateTime? horodatage;

  /// Vrai si ce message porte une proposition de prix.
  bool get estUneOffre => type == TypeMessage.offre;

  /// Vrai si l'offre attend encore une réponse et n'a pas dépassé son délai.
  ///
  /// L'expiration est évaluée à la lecture plutôt qu'écrite en base : cela
  /// évite une tâche planifiée côté serveur, hors du périmètre du projet.
  bool get offreEnAttente {
    if (!estUneOffre || !statutOffre.estOuverte) return false;
    if (horodatage == null) return true;
    return DateTime.now().difference(horodatage!) < delaiExpirationOffre;
  }

  /// Statut réellement applicable, expiration comprise.
  StatutOffre get statutEffectif {
    if (estUneOffre && statutOffre.estOuverte && !offreEnAttente) {
      return StatutOffre.expiree;
    }
    return statutOffre;
  }

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final donnees = doc.data() as Map<String, dynamic>? ?? {};
    return Message(
      id: doc.id,
      idAuteur: donnees['idAuteur'] ?? '',
      contenu: donnees['contenu'] ?? '',
      type: TypeMessage.depuisCode(donnees['type']),
      montantPropose: (donnees['montantPropose'] as num?)?.toDouble(),
      statutOffre: StatutOffre.depuisCode(donnees['statutOffre']),
      horodatage: (donnees['horodatage'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idAuteur': idAuteur,
      'contenu': contenu,
      'type': type.code,
      'montantPropose': montantPropose,
      'statutOffre': statutOffre.code,
      'horodatage':
          horodatage == null ? Timestamp.now() : Timestamp.fromDate(horodatage!),
    };
  }
}
