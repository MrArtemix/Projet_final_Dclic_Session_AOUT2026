import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../donnees/jeu_demonstration.dart';

/// Point d'entrée unique vers Firebase.
///
/// L'initialisation est volontairement tolérante. Si Firebase n'est pas
/// joignable, fichier de configuration absent, plateforme non déclarée,
/// réseau coupé, l'application démarre malgré tout en **mode démonstration**
/// et s'appuie sur le jeu de données local. Deux raisons à cela : le cahier
/// des charges exige un fonctionnement acceptable en connexion instable, et la
/// démonstration du projet ne doit jamais dépendre de la disponibilité d'un
/// service distant.
class ServiceFirebase {
  const ServiceFirebase._();

  static bool _disponible = false;

  /// Vrai lorsque Firebase a démarré et que Firestore peut être interrogé.
  static bool get disponible => _disponible;

  /// Vrai lorsque l'application fonctionne sur le jeu de données local.
  static bool get modeDemonstration => !_disponible;

  /// Instance Firestore. Ne doit être lue que si [disponible] est vrai.
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Démarre Firebase et signale si l'opération a réussi.
  static Future<bool> demarrer() async {
    try {
      await Firebase.initializeApp();

      // Le cache hors ligne de Firestore permet de relire les dernières
      // données connues sans réseau, ce qui correspond au « mode dégradé »
      // décrit au dossier de conception.
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      _disponible = true;
    } catch (erreur) {
      _disponible = false;
      debugPrint(
        'Firebase indisponible, démarrage en mode démonstration : $erreur',
      );
    }
    return _disponible;
  }

  // --- Références de collections -------------------------------------------

  static CollectionReference<Map<String, dynamic>> get utilisateurs =>
      firestore.collection('utilisateurs');

  static CollectionReference<Map<String, dynamic>> get boutiques =>
      firestore.collection('boutiques');

  static CollectionReference<Map<String, dynamic>> get produits =>
      firestore.collection('produits');

  static CollectionReference<Map<String, dynamic>> get categories =>
      firestore.collection('categories');

  static CollectionReference<Map<String, dynamic>> get conversations =>
      firestore.collection('conversations');

  static CollectionReference<Map<String, dynamic>> get avis =>
      firestore.collection('avis');

  /// Messages d'une conversation, en sous-collection.
  static CollectionReference<Map<String, dynamic>> messagesDe(
    String idConversation,
  ) =>
      conversations.doc(idConversation).collection('messages');

  /// Panier d'un utilisateur, en sous-collection de son document.
  static CollectionReference<Map<String, dynamic>> panierDe(
    String idUtilisateur,
  ) =>
      utilisateurs.doc(idUtilisateur).collection('panier');

  /// Favoris d'un utilisateur, en sous-collection de son document.
  static CollectionReference<Map<String, dynamic>> favorisDe(
    String idUtilisateur,
  ) =>
      utilisateurs.doc(idUtilisateur).collection('favoris');

  // --- Amorçage -------------------------------------------------------------

  /// Écrit le jeu de démonstration dans Firestore, une seule fois.
  ///
  /// L'écriture passe par un lot : les documents partent en une seule requête
  /// réseau, ce qui est nettement plus économe qu'un appel par document.
  /// La présence d'un document témoin évite tout doublon en cas de relance.
  static Future<bool> amorcerDonneesDemonstration() async {
    if (!_disponible) return false;

    final temoin = firestore.collection('parametres').doc('amorcage');
    final dejaFait = await temoin.get();
    if (dejaFait.exists) return false;

    final lot = firestore.batch();

    for (final categorie in JeuDemonstration.categories) {
      lot.set(categories.doc(categorie.id), categorie.toMap());
    }
    for (final boutique in JeuDemonstration.boutiques) {
      lot.set(boutiques.doc(boutique.id), boutique.toMap());
    }
    for (final produit in JeuDemonstration.produits) {
      lot.set(produits.doc(produit.id), produit.toMap());
    }
    lot.set(temoin, {'date': Timestamp.now(), 'version': 1});

    await lot.commit();
    return true;
  }
}
