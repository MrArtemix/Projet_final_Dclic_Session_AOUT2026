import 'package:flutter/foundation.dart';

import '../data/depot_panier.dart';
import '../models/article_panier.dart';
import '../models/produit.dart';

/// Panier de l'utilisateur.
///
/// Le panier vit en mémoire et se recopie dans Firestore lorsqu'un utilisateur
/// est connecté. Ce choix tient à la contrainte de réseau instable : ajouter
/// un article ne doit jamais attendre une réponse du serveur.
///
/// La règle de gestion centrale est portée par le modèle et non ici : le prix
/// d'une ligne est recalculé à chaque changement de quantité, si bien que le
/// passage au tarif de gros est automatique dès que le seuil est franchi.
class PanierController extends ChangeNotifier {
  PanierController({DepotPanier depot = const DepotPanier()}) : _depot = depot;

  /// Accès aux données, reçu à la construction : le contrôleur ignore tout de
  /// la base qui conserve le panier.
  final DepotPanier _depot;

  final List<ArticlePanier> _articles = [];

  String _idUtilisateur = '';
  String _codePromo = '';
  double _remise = 0;

  List<ArticlePanier> get articles => List.unmodifiable(_articles);

  bool get estVide => _articles.isEmpty;

  /// Nombre total d'unités, affiché sur la pastille du panier.
  int get nombreArticles =>
      _articles.fold(0, (total, article) => total + article.quantite);

  /// Somme des lignes, avant remise et livraison.
  double get sousTotal =>
      _articles.fold(0, (total, article) => total + article.sousTotal);

  /// Frais de livraison forfaitaires, en francs CFA.
  ///
  /// Ordre de grandeur d'une course en deux-roues entre deux communes
  /// d'Abidjan. La livraison longue distance relève de la version trois.
  static const double fraisLivraison = 5000;

  /// Montant du panier à partir duquel la livraison est offerte.
  static const double seuilLivraisonOfferte = 100000;

  /// Frais de livraison, offerts au-delà d'un certain montant.
  double get livraison {
    if (_articles.isEmpty) return 0;
    return sousTotal >= seuilLivraisonOfferte ? 0 : fraisLivraison;
  }

  double get remise => _remise;

  String get codePromo => _codePromo;

  double get total => (sousTotal - _remise + livraison).clamp(0, double.infinity);

  /// Vrai si au moins une ligne bénéficie du tarif de gros.
  bool get contientDuGros => _articles.any((article) => article.auTarifGros);

  /// Associe le panier à un utilisateur et recharge son contenu.
  Future<void> associerUtilisateur(String id) async {
    if (_idUtilisateur == id) return;
    _idUtilisateur = id;
    notifyListeners();
  }

  /// Ajoute un produit, ou augmente la quantité s'il est déjà présent.
  void ajouter(Produit produit, {int quantite = 1}) {
    final index = _articles.indexWhere((a) => a.produit.id == produit.id);

    if (index >= 0) {
      final ligne = _articles[index];
      _articles[index] = ligne.copieAvec(quantite: ligne.quantite + quantite);
    } else {
      _articles.add(
        ArticlePanier(id: produit.id, produit: produit, quantite: quantite),
      );
    }

    notifyListeners();
    _enregistrer();
  }

  /// Change la quantité d'une ligne. À zéro, la ligne est retirée.
  void changerQuantite(String idProduit, int quantite) {
    final index = _articles.indexWhere((a) => a.produit.id == idProduit);
    if (index < 0) return;

    if (quantite <= 0) {
      retirer(idProduit);
      return;
    }

    _articles[index] = _articles[index].copieAvec(quantite: quantite);
    notifyListeners();
    _enregistrer();
  }

  void retirer(String idProduit) {
    _articles.removeWhere((article) => article.produit.id == idProduit);
    notifyListeners();
    _enregistrer();
  }

  void vider() {
    _articles.clear();
    _codePromo = '';
    _remise = 0;
    notifyListeners();
    _enregistrer();
  }

  bool contient(String idProduit) =>
      _articles.any((article) => article.produit.id == idProduit);

  int quantiteDe(String idProduit) {
    for (final article in _articles) {
      if (article.produit.id == idProduit) return article.quantite;
    }
    return 0;
  }

  /// Applique un code promotionnel.
  ///
  /// Les codes sont pour l'instant vérifiés sur l'appareil. Une remise réelle
  /// devra être validée par le serveur, un contrôle côté client étant
  /// contournable ; le point est signalé pour la suite du projet.
  bool appliquerCodePromo(String code) {
    final saisie = code.trim().toUpperCase();

    const codes = <String, double>{
      'MEKANO10': 0.10,
      'BIENVENUE': 0.05,
      'ABIDJAN15': 0.15,
    };

    final taux = codes[saisie];
    if (taux == null) {
      _codePromo = '';
      _remise = 0;
      notifyListeners();
      return false;
    }

    _codePromo = saisie;
    _remise = sousTotal * taux;
    notifyListeners();
    return true;
  }

  void retirerCodePromo() {
    _codePromo = '';
    _remise = 0;
    notifyListeners();
  }

  /// Recopie le panier dans la base, sans bloquer l'interface.
  Future<void> _enregistrer() =>
      _depot.enregistrer(_idUtilisateur, _articles);
}
