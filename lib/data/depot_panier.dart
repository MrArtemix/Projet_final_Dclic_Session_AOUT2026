import 'package:flutter/foundation.dart';

import '../models/article_panier.dart';
import '../services/service_firebase.dart';

/// Recopie du panier dans la base.
///
/// Le panier de référence reste celui qui vit en mémoire : cette classe ne
/// fait qu'en conserver une copie. Un échec d'écriture n'interrompt donc
/// jamais un achat en cours, il est consigné, rien de plus.
class DepotPanier {
  const DepotPanier();

  bool get disponible => ServiceFirebase.disponible;

  /// Remplace le panier enregistré par celui qui est passé.
  ///
  /// L'opération est menée en lot : le panier distant ne se trouve jamais
  /// dans un état intermédiaire, où d'anciennes lignes auraient disparu sans
  /// que les nouvelles soient encore écrites.
  Future<void> enregistrer(
    String idUtilisateur,
    List<ArticlePanier> articles,
  ) async {
    if (!disponible || idUtilisateur.isEmpty) return;

    try {
      final panier = ServiceFirebase.panierDe(idUtilisateur);
      final lot = ServiceFirebase.firestore.batch();

      final existants = await panier.get();
      for (final document in existants.docs) {
        lot.delete(document.reference);
      }
      for (final article in articles) {
        lot.set(panier.doc(article.produit.id), article.toMap());
      }

      await lot.commit();
    } catch (erreur) {
      debugPrint('Enregistrement du panier : $erreur');
    }
  }
}
