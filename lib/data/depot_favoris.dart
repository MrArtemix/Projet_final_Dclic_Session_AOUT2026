import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../services/service_firebase.dart';

/// Accès aux favoris d'un compte.
///
/// Les dépôts de ce dossier tiennent le rôle que le cours confie au
/// « repository » : ils sont seuls à connaître la base et ses requêtes. Un
/// contrôleur ne manipule jamais de collection ni de document ; il demande une
/// donnée et reçoit des objets du domaine.
///
/// Trois conséquences pratiques :
///
/// * changer de base, Firestore aujourd'hui, autre chose demain, se fait
///   dans ce dossier, sans toucher aux contrôleurs ;
/// * un contrôleur devient vérifiable en test avec un dépôt de remplacement,
///   sans qu'aucun réseau soit nécessaire ;
/// * la panne se traite ici. Un dépôt n'interrompt jamais le parcours : il
///   renvoie un résultat vide ou ne fait rien, et consigne l'incident.
class DepotFavoris {
  const DepotFavoris();

  /// Vrai lorsque la base est joignable.
  bool get disponible => ServiceFirebase.disponible;

  /// Identifiants des produits mis de côté par ce compte.
  ///
  /// Renvoie un ensemble vide plutôt que de lever : l'écran doit s'afficher
  /// même si la lecture échoue.
  Future<Set<String>> lire(String idUtilisateur) async {
    if (!disponible || idUtilisateur.isEmpty) return {};

    try {
      final documents = await ServiceFirebase.favorisDe(idUtilisateur).get();
      return documents.docs.map((document) => document.id).toSet();
    } catch (erreur) {
      debugPrint('Lecture des favoris : $erreur');
      return {};
    }
  }

  /// Inscrit un produit parmi les favoris du compte.
  Future<void> ajouter(String idUtilisateur, String idProduit) =>
      _ecrire(idUtilisateur, idProduit, ajoute: true);

  /// Retire un produit des favoris du compte.
  Future<void> retirer(String idUtilisateur, String idProduit) =>
      _ecrire(idUtilisateur, idProduit, ajoute: false);

  Future<void> _ecrire(
    String idUtilisateur,
    String idProduit, {
    required bool ajoute,
  }) async {
    if (!disponible || idUtilisateur.isEmpty) return;

    try {
      final document = ServiceFirebase.favorisDe(idUtilisateur).doc(idProduit);
      if (ajoute) {
        await document.set({'horodatage': Timestamp.now()});
      } else {
        await document.delete();
      }
    } catch (erreur) {
      debugPrint('Enregistrement d\'un favori : $erreur');
    }
  }
}
