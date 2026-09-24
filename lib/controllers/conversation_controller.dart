import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/depot_conversations.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/produit.dart';

/// Négociation entre un acheteur et un vendeur.
///
/// Le dossier de conception prévoyait Socket.io pour le temps réel. Firestore
/// ayant été retenu comme base, ce sont ses flux `snapshots()` qui assurent ce
/// rôle : chaque écriture est répercutée aux participants connectés sans
/// requête supplémentaire. Cet écart est volontaire et documenté au rapport.
///
/// Le point important tient au modèle, pas au transport : une offre de prix
/// est un message typé, porteur d'un statut propre, ce qui permet de suivre la
/// négociation indépendamment du fil de discussion.
class ConversationController extends ChangeNotifier {
  ConversationController({
    DepotConversations depot = const DepotConversations(),
  }) : _depot = depot;

  /// Accès aux données, reçu à la construction : le contrôleur ignore le
  /// transport employé pour le temps réel.
  final DepotConversations _depot;

  final List<Message> _messages = [];

  StreamSubscription<List<Message>>? _abonnement;
  Conversation? _conversation;
  String _idUtilisateur = '';
  bool _chargement = false;

  List<Message> get messages => List.unmodifiable(_messages);
  Conversation? get conversation => _conversation;
  bool get chargement => _chargement;

  /// Dernière offre encore ouverte, tous auteurs confondus.
  Message? get offreEnCours {
    for (final message in _messages.reversed) {
      if (message.estUneOffre && message.statutEffectif.estOuverte) {
        return message;
      }
    }
    return null;
  }

  /// Offre acceptée qui fixe le prix convenu, le cas échéant.
  Message? get offreAcceptee {
    for (final message in _messages.reversed) {
      if (message.estUneOffre &&
          message.statutEffectif == StatutOffre.acceptee) {
        return message;
      }
    }
    return null;
  }

  /// Ouvre, ou rouvre, la conversation portant sur un produit.
  Future<void> ouvrirPour({
    required Produit produit,
    required String idUtilisateur,
    String nomVendeur = '',
  }) async {
    _idUtilisateur = idUtilisateur;
    _chargement = true;
    _messages.clear();
    notifyListeners();

    final identifiant = '${produit.id}_$idUtilisateur';

    _conversation = Conversation(
      id: identifiant,
      idProduit: produit.id,
      idAcheteur: idUtilisateur,
      idVendeur: produit.idVendeur,
      titreProduit: produit.titre,
      photoProduit: produit.photos.isEmpty ? '' : produit.photos.first,
      prixProduit: produit.prixDetail,
      nomInterlocuteur:
          nomVendeur.isNotEmpty ? nomVendeur : produit.nomBoutique,
      vendeurEnLigne: true,
      horodatage: DateTime.now(),
    );

    if (_depot.disponible) {
      await _ecouterLeFil(identifiant);
    } else {
      _chargerConversationDeDemonstration(produit);
    }

    _chargement = false;
    notifyListeners();
  }

  Future<void> _ecouterLeFil(String identifiant) async {
    try {
      await _depot.ouvrir(_conversation!);

      await _abonnement?.cancel();
      _abonnement = _depot.messages(identifiant).listen((messages) {
        _messages
          ..clear()
          ..addAll(messages);
        notifyListeners();
      });
    } catch (erreur) {
      debugPrint('Ouverture de la conversation : $erreur');
    }
  }

  /// Fil d'exemple, repris des maquettes, utilisé hors connexion.
  void _chargerConversationDeDemonstration(Produit produit) {
    final maintenant = DateTime.now();

    _messages.addAll([
      Message(
        id: 'd1',
        idAuteur: _idUtilisateur,
        contenu: 'Bonjour ! Le prix est-il négociable ?',
        horodatage: maintenant.subtract(const Duration(minutes: 12)),
      ),
      Message(
        id: 'd2',
        idAuteur: produit.idVendeur,
        contenu: 'Bonjour, oui un peu selon la quantité.',
        horodatage: maintenant.subtract(const Duration(minutes: 10)),
      ),
    ]);
  }

  /// Envoie un message texte.
  Future<void> envoyerMessage(String contenu) async {
    final texte = contenu.trim();
    if (texte.isEmpty) return;

    final message = Message(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      idAuteur: _idUtilisateur,
      contenu: texte,
      horodatage: DateTime.now(),
    );

    await _publier(message);
  }

  /// Émet une proposition de prix.
  ///
  /// Toute offre encore ouverte du même auteur est d'abord retirée : deux
  /// propositions concurrentes rendraient la négociation illisible.
  Future<void> envoyerOffre(double montant, {String commentaire = ''}) async {
    final precedente = offreEnCours;
    if (precedente != null && precedente.idAuteur == _idUtilisateur) {
      await _changerStatut(precedente, StatutOffre.refusee);
    }

    final offre = Message(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      idAuteur: _idUtilisateur,
      contenu: commentaire.trim(),
      type: TypeMessage.offre,
      montantPropose: montant,
      horodatage: DateTime.now(),
    );

    await _publier(offre);
  }

  Future<void> accepterOffre(Message offre) async {
    await _changerStatut(offre, StatutOffre.acceptee);
    await _messageSysteme(
      'Offre acceptée. Le prix convenu est de '
      '${offre.montantPropose?.round()}.',
    );
  }

  Future<void> refuserOffre(Message offre) async {
    await _changerStatut(offre, StatutOffre.refusee);
  }

  /// Refuse l'offre reçue et en propose aussitôt une autre.
  Future<void> contrerOffre(Message offre, double montant) async {
    await _changerStatut(offre, StatutOffre.refusee);
    await envoyerOffre(montant);
  }

  Future<void> _changerStatut(Message offre, StatutOffre statut) async {
    final index = _messages.indexWhere((m) => m.id == offre.id);
    if (index < 0) return;

    _messages[index] = Message(
      id: offre.id,
      idAuteur: offre.idAuteur,
      contenu: offre.contenu,
      type: offre.type,
      montantPropose: offre.montantPropose,
      statutOffre: statut,
      horodatage: offre.horodatage,
    );
    notifyListeners();

    if (_depot.disponible && _conversation != null) {
      try {
        await _depot.changerStatutOffre(_conversation!.id, offre.id, statut);
      } catch (erreur) {
        debugPrint('Mise à jour d\'une offre : $erreur');
      }
    }
  }

  Future<void> _messageSysteme(String contenu) => _publier(
        Message(
          id: 'systeme_${DateTime.now().microsecondsSinceEpoch}',
          idAuteur: 'systeme',
          contenu: contenu,
          type: TypeMessage.systeme,
          horodatage: DateTime.now(),
        ),
      );

  /// Ajoute le message localement, puis tente de l'écrire.
  ///
  /// L'affichage précède l'écriture : sur un réseau lent, attendre la
  /// confirmation du serveur donnerait une conversation poussive.
  Future<void> _publier(Message message) async {
    if (!_depot.disponible) {
      _messages.add(message);
      notifyListeners();
      return;
    }

    if (_conversation == null) return;

    try {
      // Le flux renverra le message : il n'est pas ajouté localement, ce qui
      // provoquerait un doublon passager.
      await _depot.publier(_conversation!.id, message);
    } catch (erreur) {
      debugPrint('Envoi d\'un message : $erreur');
      // L'écriture a échoué : le message est conservé localement pour que la
      // conversation reste lisible, et sera renvoyé à la reconnexion.
      _messages.add(message);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _abonnement?.cancel();
    super.dispose();
  }
}
