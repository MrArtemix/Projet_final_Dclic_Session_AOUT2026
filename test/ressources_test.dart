import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mekano_afrika/donnees/jeu_demonstration.dart';

/// Vérifie que les visuels cités par le catalogue partiront bien dans
/// l'application.
///
/// Une ressource manquante ne provoque aucune erreur de compilation : elle
/// s'affiche vide à l'exécution, et le défaut passe inaperçu jusqu'à ce que
/// quelqu'un ouvre l'écran concerné. Le piège classique tient à `pubspec.yaml`
/// : déclarer `assets/images/` ne couvre **pas** ses sous-dossiers, chacun
/// devant être nommé. Ces vérifications remplacent une inspection à l'œil, et
/// s'exécutent sans appareil.
void main() {
  /// Dossiers de ressources déclarés au manifeste.
  final declares = File('pubspec.yaml')
      .readAsLinesSync()
      .map((ligne) => ligne.trim())
      .where((ligne) => ligne.startsWith('- assets/'))
      .map((ligne) => ligne.substring(2))
      .toList();

  /// Tous les chemins cités par le jeu de démonstration.
  final cites = <String>{
    for (final boutique in JeuDemonstration.boutiques)
      if (boutique.logo.startsWith('assets/')) boutique.logo,
    for (final produit in JeuDemonstration.produits)
      ...produit.photos.where((photo) => photo.startsWith('assets/')),
  };

  test('le catalogue cite bien des ressources', () {
    expect(cites, isNotEmpty);
    expect(declares, isNotEmpty);
  });

  test('chaque ressource citée existe sur le disque', () {
    final absentes = cites.where((c) => !File(c).existsSync()).toList();
    expect(absentes, isEmpty, reason: 'fichiers introuvables : $absentes');
  });

  test('chaque ressource citée est déclarée au manifeste', () {
    // Un dossier déclaré couvre les fichiers qu'il contient directement, et
    // eux seuls.
    final nonDeclarees = cites.where((chemin) {
      final dossier = '${chemin.substring(0, chemin.lastIndexOf('/'))}/';
      return !declares.contains(dossier);
    }).toList();

    expect(
      nonDeclarees,
      isEmpty,
      reason: 'ces fichiers ne partiront pas dans l\'application, faute '
          'd\'être déclarés au pubspec : $nonDeclarees',
    );
  });

  test('aucune ressource déclarée n\'est vide ou démesurée', () {
    // Au-delà d'un mégaoctet, une image destinée à un écran de téléphone
    // signale un fichier qui a échappé à l'optimisation.
    final anomalies = <String>[];
    for (final chemin in cites) {
      final fichier = File(chemin);
      if (!fichier.existsSync()) continue;
      final octets = fichier.lengthSync();
      if (octets == 0) anomalies.add('$chemin : vide');
      if (octets > 1048576) {
        anomalies.add('$chemin : ${octets ~/ 1024} ko');
      }
    }
    expect(anomalies, isEmpty, reason: anomalies.join(', '));
  });

  test('chaque magasin porte un logo', () {
    final sansLogo = JeuDemonstration.boutiques
        .where((b) => b.logo.isEmpty)
        .map((b) => b.nom)
        .toList();
    expect(sansLogo, isEmpty, reason: 'magasins sans logo : $sansLogo');
  });
}
