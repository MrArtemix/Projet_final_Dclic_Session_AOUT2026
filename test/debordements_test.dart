import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mekano_afrika/controllers/auth_controller.dart';
import 'package:mekano_afrika/theme/theme_mekano.dart';
import 'package:mekano_afrika/views/connexion.dart';
import 'package:mekano_afrika/views/inscription.dart';
import 'package:mekano_afrika/views/onboarding.dart';
import 'package:mekano_afrika/widgets/communs/logo.dart';
import 'package:mekano_afrika/widgets/metier/carte_zone.dart';
import 'package:provider/provider.dart';

/// Traque les débordements de mise en page.
///
/// Un débordement se signale à l'exécution par les barres jaunes et noires en
/// bordure d'écran. Le défaut dépend de la taille de l'appareil : une
/// composition qui tient sur un grand téléphone déborde sur un écran de 320
/// points de large, encore très répandu sur le marché visé par le cahier des
/// charges. Le vérifier à la main demanderait autant d'appareils ; ces
/// montages le font sans aucun.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Sans cela, le banc d'essai remplace toute police par une fonte de test aux
  // glyphes carrés, sensiblement plus larges qu'Inter : les débordements
  // relevés ne seraient alors ni ceux de l'appareil, ni absents là où
  // l'appareil en montre. La marque et les symboles suivent la même logique.
  setUpAll(() async {
    Future<void> charger(String famille, List<String> fichiers) async {
      final chargeur = FontLoader(famille);
      for (final fichier in fichiers) {
        chargeur.addFont(
          File(fichier).readAsBytes().then(ByteData.sublistView),
        );
      }
      await chargeur.load();
    }

    await charger('Inter', const [
      'assets/fonts/Inter-Regular.ttf',
      'assets/fonts/Inter-Medium.ttf',
      'assets/fonts/Inter-SemiBold.ttf',
      'assets/fonts/Inter-Bold.ttf',
    ]);
    await charger('Symboles', const [
      'assets/fonts/MaterialSymbolsRounded.ttf',
    ]);
  });

  /// Écrans de référence, en points logiques.
  ///
  /// Le premier est le plus petit format encore courant, celui qui révèle les
  /// débordements ; le dernier, un grand téléphone d'aujourd'hui.
  const ecrans = <String, Size>{
    'petit écran (320 × 568)': Size(320, 568),
    'écran courant (360 × 640)': Size(360, 640),
    'grand écran (412 × 915)': Size(412, 915),
  };

  /// Monte [widget] sur un écran donné et rend la faute de mise en page s'il y
  /// en a une.
  Future<Object?> monter(
    WidgetTester tester,
    Widget widget,
    Size ecran,
  ) async {
    tester.view.physicalSize = ecran;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(theme: ThemeMekano.clair, home: widget),
    );
    await tester.pump(const Duration(seconds: 1));
    return tester.takeException();
  }

  group('Onboarding', () {
    for (final entree in ecrans.entries) {
      testWidgets('tient sur ${entree.key}', (tester) async {
        final faute = await monter(tester, const Onboarding(), entree.value);
        expect(faute, isNull, reason: 'mise en page débordée');
      });
    }
  });

  group('Connexion', () {
    for (final entree in ecrans.entries) {
      testWidgets('tient sur ${entree.key}', (tester) async {
        final faute = await monter(
          tester,
          ChangeNotifierProvider(
            create: (_) => AuthController(),
            child: const Connexion(),
          ),
          entree.value,
        );
        expect(faute, isNull, reason: 'mise en page débordée');
      });
    }
  });

  group('Inscription', () {
    for (final entree in ecrans.entries) {
      testWidgets('tient sur ${entree.key}', (tester) async {
        final faute = await monter(
          tester,
          ChangeNotifierProvider(
            create: (_) => AuthController(),
            child: const Inscription(),
          ),
          entree.value,
        );
        expect(faute, isNull, reason: 'mise en page débordée');
      });
    }
  });

  group('Carte de zone', () {
    for (final entree in ecrans.entries) {
      testWidgets('tient sur ${entree.key}', (tester) async {
        final faute = await monter(
          tester,
          const Scaffold(
            body: Center(
              child: CarteZone(
                nomZone: 'Cocody',
                latitude: 5.36,
                longitude: -3.98,
                rayonKm: 5,
              ),
            ),
          ),
          entree.value,
        );
        expect(faute, isNull, reason: 'mise en page débordée');
      });
    }

    testWidgets('sans tuiles, le fond dessiné prend la place', (tester) async {
      await monter(
        tester,
        const Scaffold(
          body: Center(
            child: CarteZone(
              nomZone: 'Cocody',
              latitude: 5.36,
              longitude: -3.98,
              rayonKm: 5,
            ),
          ),
        ),
        const Size(360, 640),
      );

      // Le banc de test n'a pas de réseau. La bascule vient soit de l'échec
      // d'une tuile, soit du délai de garde de six secondes ; on laisse
      // passer largement de quoi couvrir les deux.
      for (var i = 0;
          i < 40 && find.text('Carte hors ligne').evaluate().isEmpty;
          i++) {
        await tester.pump(const Duration(milliseconds: 250));
      }

      expect(find.text('Carte hors ligne'), findsOneWidget);
    });
  });

  group('Logo', () {
    for (final entree in ecrans.entries) {
      testWidgets('la constellation tient sur ${entree.key}', (tester) async {
        final faute = await monter(
          tester,
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: LogoMekano(
                  taille: LogoMekano.tailleDeploye(context),
                  nomEnColonne: true,
                  surFondSombre: true,
                  constellation: true,
                ),
              ),
            ),
          ),
          entree.value,
        );
        expect(faute, isNull, reason: 'mise en page débordée');
      });
    }
  });
}
