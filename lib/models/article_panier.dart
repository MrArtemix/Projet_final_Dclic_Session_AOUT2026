import 'package:cloud_firestore/cloud_firestore.dart';

import 'produit.dart';

/// Une ligne du panier.
///
/// Le prix unitaire n'est pas figé à l'ajout : il est recalculé à partir du
/// produit et de la quantité, afin que la bascule entre tarif de détail et
/// tarif de gros suive les changements de quantité. C'est la règle de gestion
/// énoncée au dossier de conception.
class ArticlePanier {
  const ArticlePanier({
    required this.id,
    required this.produit,
    this.quantite = 1,
  });

  final String id;
  final Produit produit;
  final int quantite;

  /// Prix unitaire applicable à la quantité retenue.
  double get prixUnitaire => produit.prixPour(quantite);

  /// Montant de la ligne.
  double get sousTotal => prixUnitaire * quantite;

  /// Vrai lorsque la ligne bénéficie du tarif de gros.
  bool get auTarifGros => produit.palierGrosAtteint(quantite);

  ArticlePanier copieAvec({int? quantite}) => ArticlePanier(
        id: id,
        produit: produit,
        quantite: quantite ?? this.quantite,
      );

  Map<String, dynamic> toMap() {
    return {
      'idProduit': produit.id,
      'quantite': quantite,
      'horodatage': Timestamp.now(),
    };
  }
}
