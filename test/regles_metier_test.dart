import 'package:flutter_test/flutter_test.dart';
import 'package:mekano_afrika/models/article_panier.dart';
import 'package:mekano_afrika/models/message.dart';
import 'package:mekano_afrika/models/produit.dart';

/// Vérification des règles de gestion énoncées au dossier de conception.
void main() {
  // Un produit proposé à 45 l'unité, ou 38 à partir de dix pièces.
  const avecPalier = Produit(
    id: 'p1',
    idVendeur: 'v1',
    titre: 'Ordinateur portable HP EliteBook 840',
    prixDetail: 45,
    prixGros: 38,
    seuilGros: 10,
  );

  const sansPalier = Produit(
    id: 'p2',
    idVendeur: 'v1',
    titre: 'Souris sans fil',
    prixDetail: 12,
  );

  group('Bascule entre tarif de détail et tarif de gros', () {
    test('sous le seuil, le tarif de détail s\'applique', () {
      expect(avecPalier.prixPour(1), 45);
      expect(avecPalier.prixPour(9), 45);
      expect(avecPalier.palierGrosAtteint(9), isFalse);
    });

    test('au seuil exact, le tarif de gros s\'applique', () {
      expect(avecPalier.prixPour(10), 38);
      expect(avecPalier.palierGrosAtteint(10), isTrue);
    });

    test('au-delà du seuil, le tarif de gros reste appliqué', () {
      expect(avecPalier.prixPour(25), 38);
    });

    test('sans palier renseigné, le tarif de détail vaut pour toute quantité', () {
      expect(sansPalier.aUnPalierGros, isFalse);
      expect(sansPalier.prixPour(100), 12);
      expect(sansPalier.palierGrosAtteint(100), isFalse);
    });
  });

  group('Réduction affichée sur une annonce', () {
    test('un prix antérieur plus élevé donne un pourcentage', () {
      const enPromotion = Produit(
        id: 'p3',
        idVendeur: 'v1',
        titre: 'Mémoire RAM 8 Go',
        prixDetail: 45,
        prixAvant: 60,
      );
      expect(enPromotion.pourcentageReduction, 25);
    });

    test('sans prix antérieur, aucune réduction n\'est affichée', () {
      expect(sansPalier.pourcentageReduction, isNull);
    });

    test('un prix antérieur incohérent est ignoré', () {
      const incoherent = Produit(
        id: 'p4',
        idVendeur: 'v1',
        titre: 'Clavier',
        prixDetail: 30,
        prixAvant: 20,
      );
      expect(incoherent.pourcentageReduction, isNull);
    });
  });

  group('Total du panier', () {
    test('une ligne au tarif de gros est valorisée au bon prix', () {
      const ligne = ArticlePanier(id: 'a1', produit: avecPalier, quantite: 12);
      expect(ligne.auTarifGros, isTrue);
      expect(ligne.prixUnitaire, 38);
      expect(ligne.sousTotal, 456);
    });

    test('changer la quantité rebascule le tarif de la ligne', () {
      const ligne = ArticlePanier(id: 'a1', produit: avecPalier, quantite: 2);
      expect(ligne.sousTotal, 90);

      final augmentee = ligne.copieAvec(quantite: 10);
      expect(augmentee.auTarifGros, isTrue);
      expect(augmentee.sousTotal, 380);

      final reduite = augmentee.copieAvec(quantite: 3);
      expect(reduite.auTarifGros, isFalse);
      expect(reduite.sousTotal, 135);
    });
  });

  group('Statut d\'une offre de prix', () {
    test('une offre récente reste ouverte', () {
      final offre = Message(
        id: 'm1',
        idAuteur: 'acheteur',
        contenu: '',
        type: TypeMessage.offre,
        montantPropose: 40,
        horodatage: DateTime.now().subtract(const Duration(hours: 2)),
      );
      expect(offre.offreEnAttente, isTrue);
      expect(offre.statutEffectif, StatutOffre.attente);
    });

    test('une offre sans réponse au-delà du délai devient expirée', () {
      final offre = Message(
        id: 'm2',
        idAuteur: 'acheteur',
        contenu: '',
        type: TypeMessage.offre,
        montantPropose: 40,
        horodatage: DateTime.now().subtract(const Duration(hours: 72)),
      );
      expect(offre.offreEnAttente, isFalse);
      expect(offre.statutEffectif, StatutOffre.expiree);
    });

    test('une offre acceptée le reste, quelle que soit son ancienneté', () {
      final offre = Message(
        id: 'm3',
        idAuteur: 'acheteur',
        contenu: '',
        type: TypeMessage.offre,
        montantPropose: 40,
        statutOffre: StatutOffre.acceptee,
        horodatage: DateTime.now().subtract(const Duration(days: 30)),
      );
      expect(offre.statutEffectif, StatutOffre.acceptee);
      expect(offre.offreEnAttente, isFalse);
    });

    test('un message texte ancien n\'est jamais traité comme une offre', () {
      final texte = Message(
        id: 'm4',
        idAuteur: 'vendeur',
        contenu: 'Bonjour, oui un peu selon la quantité.',
        horodatage: DateTime.now().subtract(const Duration(days: 10)),
      );
      expect(texte.estUneOffre, isFalse);
      expect(texte.offreEnAttente, isFalse);
      expect(texte.statutEffectif, StatutOffre.attente);
    });
  });

  group('Formes d\'échange acceptées', () {
    test('une annonce de vente simple n\'accepte pas le troc', () {
      expect(TypeTransaction.vente.accepteVente, isTrue);
      expect(TypeTransaction.vente.accepteTroc, isFalse);
    });

    test('une annonce mixte accepte les deux formes', () {
      expect(TypeTransaction.lesDeux.accepteVente, isTrue);
      expect(TypeTransaction.lesDeux.accepteTroc, isTrue);
    });

    test('une annonce de troc seul n\'est pas achetable au prix affiché', () {
      expect(TypeTransaction.troc.accepteVente, isFalse);
      expect(TypeTransaction.troc.accepteTroc, isTrue);
    });
  });
}
