import 'package:flutter_test/flutter_test.dart';
import 'package:mekano_afrika/controllers/panier_controller.dart';
import 'package:mekano_afrika/models/produit.dart';

/// Le panier porte la règle la plus visible pour l'utilisateur : le prix qu'il
/// va payer. Chaque cas de bascule entre détail et gros est donc vérifié.
void main() {
  const portable = Produit(
    id: 'p_elitebook',
    idVendeur: 'v1',
    titre: 'HP EliteBook 840',
    prixDetail: 45000,
    prixGros: 38000,
    seuilGros: 10,
  );

  const souris = Produit(
    id: 'p_souris',
    idVendeur: 'v1',
    titre: 'Souris sans fil',
    prixDetail: 12000,
  );

  late PanierController panier;

  setUp(() => panier = PanierController());

  group('Contenu du panier', () {
    test('un panier neuf est vide', () {
      expect(panier.estVide, isTrue);
      expect(panier.nombreArticles, 0);
      expect(panier.total, 0);
    });

    test('ajouter deux fois le même produit cumule les quantités', () {
      panier.ajouter(portable);
      panier.ajouter(portable, quantite: 2);

      expect(panier.articles.length, 1);
      expect(panier.quantiteDe('p_elitebook'), 3);
    });

    test('mettre la quantité à zéro retire la ligne', () {
      panier.ajouter(souris, quantite: 2);
      panier.changerQuantite('p_souris', 0);

      expect(panier.contient('p_souris'), isFalse);
      expect(panier.estVide, isTrue);
    });
  });

  group('Bascule vers le tarif de gros', () {
    test('sous le seuil, le panier reste au tarif de détail', () {
      panier.ajouter(portable, quantite: 4);

      expect(panier.contientDuGros, isFalse);
      expect(panier.sousTotal, 180000); // 4 × 45 000
    });

    test('au seuil, le panier entier passe au tarif de gros', () {
      panier.ajouter(portable, quantite: 10);

      expect(panier.contientDuGros, isTrue);
      expect(panier.sousTotal, 380000); // 10 × 38 000
    });

    test('redescendre sous le seuil rétablit le tarif de détail', () {
      panier.ajouter(portable, quantite: 12);
      expect(panier.sousTotal, 456000);

      panier.changerQuantite('p_elitebook', 5);
      expect(panier.contientDuGros, isFalse);
      expect(panier.sousTotal, 225000); // 5 × 45 000
    });

    test('les lignes sont valorisées indépendamment', () {
      panier.ajouter(portable, quantite: 10); // au gros : 380 000
      panier.ajouter(souris, quantite: 3); // au détail : 36 000

      expect(panier.sousTotal, 416000);
      expect(panier.contientDuGros, isTrue);
    });
  });

  group('Livraison et remise', () {
    test('la livraison est facturée sous le seuil', () {
      panier.ajouter(souris, quantite: 2); // 24 000
      expect(panier.livraison, PanierController.fraisLivraison);
      expect(panier.total, 29000);
    });

    test('la livraison est offerte au-delà du seuil', () {
      panier.ajouter(portable, quantite: 3); // 135 000
      expect(panier.livraison, 0);
      expect(panier.total, 135000);
    });

    test('un code promo valide réduit le total', () {
      panier.ajouter(portable, quantite: 2); // 90 000

      expect(panier.appliquerCodePromo('mekano10'), isTrue);
      expect(panier.remise, closeTo(9000, 0.001));
      expect(panier.total, closeTo(86000, 0.001)); // 90 000 - 9 000 + 5 000
    });

    test('un code inconnu est refusé et n\'applique aucune remise', () {
      panier.ajouter(portable, quantite: 2);

      expect(panier.appliquerCodePromo('INCONNU'), isFalse);
      expect(panier.remise, 0);
      expect(panier.codePromo, isEmpty);
    });

    test('vider le panier annule aussi la remise', () {
      panier.ajouter(portable, quantite: 2);
      panier.appliquerCodePromo('MEKANO10');
      panier.vider();

      expect(panier.estVide, isTrue);
      expect(panier.remise, 0);
      expect(panier.total, 0);
    });
  });
}
