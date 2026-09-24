import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/localisation_controller.dart';
import '../theme/couleurs.dart';
import '../theme/dimensions.dart';
import '../theme/typographie.dart';
import '../widgets/communs/fond_texture.dart';
import '../widgets/communs/logo.dart';
import 'onboarding.dart';

/// Écran de chargement.
///
/// Il met à profit le temps d'affichage du logo pour restaurer la session et
/// préparer la position de repli, afin que l'écran suivant s'ouvre déjà prêt.
class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _preparer();
  }

  Future<void> _preparer() async {
    final auth = context.read<AuthController>();
    final localisation = context.read<LocalisationController>();

    // Durée minimale d'affichage : sans elle, le logo clignote sur un
    // téléphone rapide, ce qui donne une impression de défaut.
    final attente = Future<void>.delayed(const Duration(milliseconds: 1600));

    await Future.wait([auth.restaurerSession(), attente]);
    localisation.appliquerPositionParDefaut();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Mouvement.normal,
        pageBuilder: (_, _, _) => const Onboarding(),
        transitionsBuilder: (_, animation, _, enfant) =>
            FadeTransition(opacity: animation, child: enfant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.nuit,
      body: FondNuit(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              LogoMekano(
                taille: LogoMekano.tailleDeploye(context),
                nomEnColonne: true,
                surFondSombre: true,
                constellation: true,
              )
                  .animate()
                  .fadeIn(duration: Mouvement.ample)
                  .scale(
                    begin: const Offset(0.92, 0.92),
                    end: const Offset(1, 1),
                    duration: Mouvement.ample,
                    curve: Mouvement.courbeRessort,
                  ),
              const SizedBox(height: Espaces.xxxl),
              SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  backgroundColor: Couleurs.orange.withValues(alpha: 0.22),
                ),
              ).animate(delay: Mouvement.rapide).fadeIn(),
              const Spacer(flex: 4),
              Text(
                'Chargement...',
                style: Typographie.echelle.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Couleurs.encreInverseDouce,
                ),
              ).animate(delay: Mouvement.normal).fadeIn(),
              const SizedBox(height: Espaces.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
