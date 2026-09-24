import 'package:flutter/foundation.dart';

import '../data/depot_favoris.dart';

/// Produits mis de côté par l'utilisateur.
///
/// Le basculement est immédiat à l'écran, l'écriture distante suit. Sur un
/// réseau lent, attendre la confirmation du serveur rendrait le cœur de la
/// carte produit poussif.
class FavorisController extends ChangeNotifier {
  FavorisController({DepotFavoris depot = const DepotFavoris()})
      : _depot = depot;

  /// Accès aux données, reçu à la construction.
  ///
  /// C'est ce qui permet de vérifier le contrôleur avec un dépôt de
  /// remplacement, sans base ni réseau.
  final DepotFavoris _depot;

  final Set<String> _identifiants = {};
  String _idUtilisateur = '';

  Set<String> get identifiants => Set.unmodifiable(_identifiants);

  int get nombre => _identifiants.length;

  bool estFavori(String idProduit) => _identifiants.contains(idProduit);

  /// Charge les favoris du compte.
  Future<void> charger(String idUtilisateur) async {
    _idUtilisateur = idUtilisateur;

    final identifiants = await _depot.lire(idUtilisateur);
    if (identifiants.isEmpty) return;

    _identifiants
      ..clear()
      ..addAll(identifiants);
    notifyListeners();
  }

  /// Ajoute ou retire un produit des favoris.
  void basculer(String idProduit) {
    final etaitFavori = _identifiants.contains(idProduit);

    if (etaitFavori) {
      _identifiants.remove(idProduit);
      _depot.retirer(_idUtilisateur, idProduit);
    } else {
      _identifiants.add(idProduit);
      _depot.ajouter(_idUtilisateur, idProduit);
    }
    notifyListeners();
  }
}
