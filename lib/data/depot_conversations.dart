import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import '../services/service_firebase.dart';

/// Accès aux négociations : fil de discussion et offres de prix.
///
/// Ce dépôt est le seul de l'application à exposer un flux. Le dossier de
/// conception prévoyait Socket.io pour le temps réel ; Firestore ayant été
/// retenu comme base, ce sont ses `snapshots()` qui tiennent ce rôle. En
/// confinant le mécanisme ici, un changement de transport, revenir à
/// Socket.io, par exemple, ne toucherait pas le contrôleur, qui ne voit qu'un
/// `Stream` de messages du domaine.
class DepotConversations {
  const DepotConversations();

  bool get disponible => ServiceFirebase.disponible;

  /// Crée la conversation si elle n'existe pas, sans écraser l'existante.
  Future<void> ouvrir(Conversation conversation) async {
    if (!disponible) return;
    await ServiceFirebase.conversations
        .doc(conversation.id)
        .set(conversation.toMap(), SetOptions(merge: true));
  }

  /// Fil des messages, du plus ancien au plus récent.
  ///
  /// Chaque écriture est répercutée aux participants connectés sans requête
  /// supplémentaire.
  Stream<List<Message>> messages(String idConversation) =>
      ServiceFirebase.messagesDe(idConversation)
          .orderBy('horodatage')
          .snapshots()
          .map((instantane) =>
              instantane.docs.map(Message.fromFirestore).toList());

  /// Écrit un message et met à jour l'aperçu de la conversation.
  ///
  /// Laisse remonter l'échec : c'est au contrôleur de décider s'il conserve le
  /// message localement pour que la discussion reste lisible.
  Future<void> publier(String idConversation, Message message) async {
    await ServiceFirebase.messagesDe(idConversation)
        .doc(message.id)
        .set(message.toMap());

    await ServiceFirebase.conversations.doc(idConversation).update({
      'dernierMessage': message.estUneOffre
          ? 'Offre : ${message.montantPropose?.round()}'
          : message.contenu,
      'horodatage': Timestamp.now(),
    });
  }

  /// Inscrit la réponse donnée à une offre : acceptée, refusée ou expirée.
  Future<void> changerStatutOffre(
    String idConversation,
    String idOffre,
    StatutOffre statut,
  ) async {
    if (!disponible) return;
    await ServiceFirebase.messagesDe(idConversation)
        .doc(idOffre)
        .update({'statutOffre': statut.code});
  }
}
