import 'package:flutter/foundation.dart';

import '../models/boutique.dart';
import '../models/categorie.dart';
import '../models/produit.dart';
import '../services/service_firebase.dart';

/// Contenu du catalogue tel qu'il est lu dans la base.
///
/// Les trois collections voyagent ensemble : une annonce sans sa boutique ni
/// sa catégorie ne s'affiche pas correctement.
class ContenuCatalogue {
  const ContenuCatalogue({
    required this.produits,
    required this.boutiques,
    required this.categories,
  });

  /// Catalogue vide, renvoyé lorsque la base est injoignable ou encore vierge.
  const ContenuCatalogue.vide()
      : produits = const [],
        boutiques = const [],
        categories = const [];

  final List<Produit> produits;
  final List<Boutique> boutiques;
  final List<Categorie> categories;

  /// Une base encore vierge n'est pas une erreur : l'appelant se rabat alors
  /// sur le jeu local.
  bool get estVide => produits.isEmpty;
}

/// Accès au catalogue : annonces, boutiques et catégories.
class DepotCatalogue {
  const DepotCatalogue();

  bool get disponible => ServiceFirebase.disponible;

  /// Écrit le jeu de démonstration dans la base, si elle est vide.
  ///
  /// Sert à garnir une base neuve depuis l'écran de compte, sans passer par
  /// une console d'administration.
  Future<bool> amorcerDonneesDemonstration() =>
      ServiceFirebase.amorcerDonneesDemonstration();

  /// Lit les trois collections en une fois.
  ///
  /// Les requêtes sont lancées de front plutôt que l'une après l'autre : sur
  /// un réseau lent, les enchaîner tripleraient l'attente avant le premier
  /// affichage.
  Future<ContenuCatalogue> lire() async {
    if (!disponible) return const ContenuCatalogue.vide();

    try {
      final resultats = await Future.wait([
        ServiceFirebase.produits.get(),
        ServiceFirebase.boutiques.get(),
        ServiceFirebase.categories.get(),
      ]);

      return ContenuCatalogue(
        produits: resultats[0].docs.map(Produit.fromFirestore).toList(),
        boutiques: resultats[1].docs.map(Boutique.fromFirestore).toList(),
        categories: resultats[2].docs.map(Categorie.fromFirestore).toList(),
      );
    } catch (erreur) {
      debugPrint('Lecture du catalogue : $erreur');
      rethrow;
    }
  }
}
