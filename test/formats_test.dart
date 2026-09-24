import 'package:flutter_test/flutter_test.dart';
import 'package:mekano_afrika/utils/formats.dart';

/// Les mises en forme sont visibles sur presque tous les écrans : un écart de
/// présentation se remarque immédiatement, d'où ces vérifications.
void main() {
  group('Formats.prix', () {
    test('la devise suit le nombre, comme le veut l\'usage local', () {
      expect(Formats.prix(45), '45\u00A0FCFA');
      expect(Formats.prix(12), '12\u00A0FCFA');
    });

    test('un montant décimal est arrondi', () {
      expect(Formats.prix(45.4), '45\u00A0FCFA');
      expect(Formats.prix(45.6), '46\u00A0FCFA');
    });

    test('les milliers sont séparés', () {
      expect(Formats.montantSeul(1200), matches(r'^1\s200$'));
      expect(Formats.prix(1200).endsWith('200\u00A0FCFA'), isTrue);
    });

    test('l\'espace qui précède la devise est insécable', () {
      expect(Formats.prix(45).contains('\u00A0FCFA'), isTrue);
      expect(Formats.prix(45).contains(' FCFA'), isFalse);
    });
  });

  group('Formats.montantSeul', () {
    test('le montant est rendu sans devise', () {
      expect(Formats.montantSeul(45), '45');
      expect(Formats.montantSeul(45.6), '46');
      expect(Formats.montantSeul(1200).contains('FCFA'), isFalse);
    });
  });

  group('Formats.note', () {
    test('une note garde toujours une décimale', () {
      expect(Formats.note(4.5), '4.5');
      expect(Formats.note(5), '5.0');
      expect(Formats.note(4.75), '4.8');
    });
  });

  group('Formats.compteurAbrege', () {
    test('en dessous de mille, la valeur est inchangée', () {
      expect(Formats.compteurAbrege(128), '128');
      expect(Formats.compteurAbrege(999), '999');
    });

    test('les milliers sont abrégés avec une décimale', () {
      expect(Formats.compteurAbrege(1200), '1.2k');
      expect(Formats.compteurAbrege(3400), '3.4k');
    });

    test('au-delà de dix mille, la décimale disparaît', () {
      expect(Formats.compteurAbrege(23400), '23k');
    });
  });
}
