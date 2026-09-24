import 'package:flutter_test/flutter_test.dart';
import 'package:mekano_afrika/utils/distance.dart';

/// La distance remplace l'opérateur géospatial de PostGIS prévu au dossier de
/// conception : elle est donc vérifiée point par point.
void main() {
  group('Distance.entre', () {
    test('deux points identiques sont à distance nulle', () {
      expect(Distance.entre(5.36, -3.98, 5.36, -3.98), 0);
    });

    test('un degré de latitude vaut environ 111 kilomètres', () {
      final km = Distance.entre(5.0, -4.0, 6.0, -4.0);
      expect(km, closeTo(111.19, 0.5));
    });

    test('la distance est symétrique', () {
      final aller = Distance.entre(5.32, -4.02, 5.36, -3.98);
      final retour = Distance.entre(5.36, -3.98, 5.32, -4.02);
      expect(aller, closeTo(retour, 1e-9));
    });

    test('du Plateau à Cocody, environ six kilomètres', () {
      // Coordonnées des deux communes d'Abidjan utilisées par l'application.
      final km = Distance.entre(5.3200, -4.0200, 5.3600, -3.9800);
      expect(km, greaterThan(5));
      expect(km, lessThan(7));
    });

    test('tient sur de longues distances : Abidjan vers Bouaké', () {
      final km = Distance.entre(5.3600, -4.0083, 7.6900, -5.0300);
      expect(km, closeTo(281, 10));
    });

    test('gère le passage du méridien de Greenwich', () {
      final km = Distance.entre(5.0, -0.5, 5.0, 0.5);
      expect(km, closeTo(110.7, 1));
    });
  });

  group('Distance.formater', () {
    test('en dessous de cent mètres, mention de proximité', () {
      expect(Distance.formater(0.05), 'Tout près');
    });

    test('en dessous du kilomètre, arrondi à la centaine de mètres', () {
      expect(Distance.formater(0.42), 'À 400m');
      expect(Distance.formater(0.86), 'À 900m');
    });

    test('la décimale nulle n\'est pas affichée', () {
      expect(Distance.formater(2.0), 'À 2km');
    });

    test('une décimale est conservée sous dix kilomètres', () {
      expect(Distance.formater(3.47), 'À 3.5km');
    });

    test('au-delà de dix kilomètres, arrondi au kilomètre', () {
      expect(Distance.formater(23.6), 'À 24km');
    });
  });
}
