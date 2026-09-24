import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/symboles.dart';

/// Classification des annonces.
///
/// Le dossier de conception prévoit une hiérarchie : une catégorie peut avoir
/// un parent, ce qui permettra d'ajouter des sous-catégories sans reprendre le
/// modèle. Le nom de l'icône est stocké sous forme de texte afin que la liste
/// des catégories reste entièrement administrable depuis Firestore.
class Categorie {
  const Categorie({
    required this.id,
    required this.nom,
    this.nomIcone = 'category',
    this.idParent = '',
    this.nbProduits = 0,
  });

  final String id;
  final String nom;
  final String nomIcone;
  final String idParent;
  final int nbProduits;

  /// Vrai lorsque la catégorie est de premier niveau.
  bool get estRacine => idParent.isEmpty;

  /// Icône correspondant au nom stocké.
  ///
  /// Les icônes sont résolues par une table explicite : Flutter supprime à la
  /// compilation les icônes qu'il ne voit pas référencées, ce qui rend
  /// impossible une résolution dynamique par code de caractère.
  IconData get icone => _icones[nomIcone] ?? Symboles.category;

  static const Map<String, IconData> _icones = {
    'ordinateur': Symboles.laptopMac,
    'telephone': Symboles.smartphone,
    'audio': Symboles.headphones,
    'composant': Symboles.memory,
    'reseau': Symboles.router,
    'accessoire': Symboles.cable,
    'photo': Symboles.photoCamera,
    'ecran': Symboles.monitor,
    'impression': Symboles.print,
    'energie': Symboles.batteryChargingFull,
    'category': Symboles.category,
  };

  factory Categorie.fromFirestore(DocumentSnapshot doc) {
    final donnees = doc.data() as Map<String, dynamic>? ?? {};
    return Categorie(
      id: doc.id,
      nom: donnees['nom'] ?? '',
      nomIcone: donnees['nomIcone'] ?? 'category',
      idParent: donnees['idParent'] ?? '',
      nbProduits: donnees['nbProduits'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'nomIcone': nomIcone,
      'idParent': idParent,
      'nbProduits': nbProduits,
    };
  }
}
