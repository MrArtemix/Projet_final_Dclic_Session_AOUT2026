import 'package:flutter_test/flutter_test.dart';
import 'package:mekano_afrika/controllers/favoris_controller.dart';
import 'package:mekano_afrika/controllers/produit_controller.dart';
import 'package:mekano_afrika/data/depot_catalogue.dart';
import 'package:mekano_afrika/data/depot_favoris.dart';
import 'package:mekano_afrika/models/boutique.dart';
import 'package:mekano_afrika/models/categorie.dart';
import 'package:mekano_afrika/models/produit.dart';

/// Ces vérifications portent sur l'architecture elle-même.
///
/// Elles n'existaient pas tant que les contrôleurs interrogeaient la base :
/// il aurait fallu un émulateur Firestore, un réseau et un jeu de données
/// distant pour éprouver trois lignes de logique. Depuis que la source de
/// données est reçue à la construction, il suffit d'en fournir une autre.
///
/// C'est l'argument concret de la séparation en couches : non pas la beauté
/// du découpage, mais ce qu'il rend vérifiable.

/// Dépôt de remplacement : répond de mémoire et retient ce qu'on lui écrit.
class FauxDepotFavoris implements DepotFavoris {
  FauxDepotFavoris({Set<String>? existants})
      : enregistres = {...?existants};

  final Set<String> enregistres;
  int ecritures = 0;

  @override
  bool get disponible => true;

  @override
  Future<Set<String>> lire(String idUtilisateur) async => {...enregistres};

  @override
  Future<void> ajouter(String idUtilisateur, String idProduit) async {
    enregistres.add(idProduit);
    ecritures++;
  }

  @override
  Future<void> retirer(String idUtilisateur, String idProduit) async {
    enregistres.remove(idProduit);
    ecritures++;
  }
}

/// Dépôt de catalogue dont on choisit la réponse : contenu, vide, ou panne.
class FauxDepotCatalogue implements DepotCatalogue {
  FauxDepotCatalogue({this.contenu, this.enPanne = false});

  final ContenuCatalogue? contenu;
  final bool enPanne;

  @override
  bool get disponible => true;

  @override
  Future<ContenuCatalogue> lire() async {
    if (enPanne) throw Exception('base injoignable');
    return contenu ?? const ContenuCatalogue.vide();
  }

  @override
  Future<bool> amorcerDonneesDemonstration() async => false;
}

void main() {
  group('Favoris', () {
    test('les favoris du compte sont repris du dépôt', () async {
      final depot = FauxDepotFavoris(existants: {'p_souris', 'p_clavier'});
      final favoris = FavorisController(depot: depot);

      await favoris.charger('u1');

      expect(favoris.nombre, 2);
      expect(favoris.estFavori('p_souris'), isTrue);
      expect(favoris.estFavori('p_inconnu'), isFalse);
    });

    test('mettre en favori se voit à l\'écran avant d\'être écrit', () async {
      final depot = FauxDepotFavoris();
      final favoris = FavorisController(depot: depot);
      await favoris.charger('u1');

      favoris.basculer('p_souris');

      // L'état local a déjà changé, sans attendre la confirmation du dépôt.
      expect(favoris.estFavori('p_souris'), isTrue);

      await Future<void>.delayed(Duration.zero);
      expect(depot.enregistres, contains('p_souris'));
      expect(depot.ecritures, 1);
    });

    test('un second appui retire le favori', () async {
      final depot = FauxDepotFavoris(existants: {'p_souris'});
      final favoris = FavorisController(depot: depot);
      await favoris.charger('u1');

      favoris.basculer('p_souris');

      expect(favoris.estFavori('p_souris'), isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(depot.enregistres, isEmpty);
    });
  });

  group('Catalogue', () {
    const produit = Produit(
      id: 'p_test',
      idVendeur: 'v1',
      titre: 'Écran 24 pouces',
      prixDetail: 65000,
    );

    test('le catalogue distant est repris tel quel', () async {
      final catalogue = ProduitController(
        depot: FauxDepotCatalogue(
          contenu: const ContenuCatalogue(
            produits: [produit],
            boutiques: <Boutique>[],
            categories: <Categorie>[],
          ),
        ),
      );

      await catalogue.charger();

      expect(catalogue.produits.length, 1);
      expect(catalogue.produits.first.titre, 'Écran 24 pouces');
      expect(catalogue.erreur, isEmpty);
    });

    test('une base vide fait basculer sur le jeu local', () async {
      final catalogue = ProduitController(depot: FauxDepotCatalogue());

      await catalogue.charger();

      // Le parcours ne s'interrompt pas : le jeu de démonstration prend le
      // relais, et rien n'est signalé comme une erreur.
      expect(catalogue.produits, isNotEmpty);
      expect(catalogue.erreur, isEmpty);
    });

    test('une base injoignable affiche le jeu local et le signale', () async {
      final catalogue = ProduitController(
        depot: FauxDepotCatalogue(enPanne: true),
      );

      await catalogue.charger();

      expect(catalogue.produits, isNotEmpty);
      expect(catalogue.erreur, isNotEmpty);
    });

    test('le chargement s\'achève toujours', () async {
      final catalogue = ProduitController(
        depot: FauxDepotCatalogue(enPanne: true),
      );

      await catalogue.charger();

      expect(catalogue.chargement, isFalse);
    });
  });
}
