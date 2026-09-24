import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/localisation_controller.dart';
import '../theme/couleurs.dart';
import '../theme/dimensions.dart';
import '../theme/symboles.dart';
import '../theme/typographie.dart';
import '../widgets/communs/boutons.dart';
import '../widgets/communs/fond_texture.dart';
import 'accueil.dart';
import 'choisir_zone.dart';

/// Demande d'autorisation de localisation.
///
/// Règle du cahier des charges appliquée ici : la permission est demandée au
/// premier lancement, mais **son refus n'interrompt jamais le parcours**.
/// Trois issues mènent toutes à l'accueil, autoriser, choisir sa zone à la
/// main, ou passer l'étape, et aucune n'est un cul-de-sac.
class AutoriserLocalisation extends StatefulWidget {
  const AutoriserLocalisation({super.key});

  @override
  State<AutoriserLocalisation> createState() => _AutoriserLocalisationState();
}

class _AutoriserLocalisationState extends State<AutoriserLocalisation> {
  Future<void> _autoriser() async {
    final localisation = context.read<LocalisationController>();
    final obtenue = await localisation.localiser();

    if (!mounted) return;

    if (obtenue) {
      await _memoriser();
      if (!mounted) return;
      _entrer();
      return;
    }

    // Échec ou refus : l'utilisateur est renvoyé vers la sélection manuelle,
    // avec l'explication de ce qui s'est passé.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localisation.message),
        action: SnackBarAction(
          label: 'Choisir',
          onPressed: _choisirZone,
        ),
      ),
    );
  }

  Future<void> _memoriser() async {
    final localisation = context.read<LocalisationController>();
    if (!localisation.aUnePosition) return;

    await context.read<AuthController>().memoriserPosition(
          latitude: localisation.latitude!,
          longitude: localisation.longitude!,
          commune: localisation.commune?.nom ?? '',
        );
  }

  void _choisirZone() => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ChoisirZone()),
      );

  /// Passer l'étape : l'application retient une zone par défaut afin que les
  /// distances restent affichables dès le premier écran.
  void _passer() {
    context.read<LocalisationController>().appliquerPositionParDefaut();
    _entrer();
  }

  void _entrer() => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const Accueil()),
        (route) => false,
      );

  @override
  Widget build(BuildContext context) {
    final localisation = context.watch<LocalisationController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FondTexture(
        ambiance: AmbianceFond.chaude,
        child: SafeArea(
          child: Padding(
            padding: Espaces.ecran,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _passer,
                    child: Text(
                      'Passer',
                      style: Typographie.echelle.labelMedium,
                    ),
                  ),
                ),
                const Spacer(flex: 2),

                const _PastilleLocalisation()
                    .animate()
                    .fadeIn(duration: Mouvement.ample)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      curve: Mouvement.courbeRessort,
                    ),

                const Spacer(),
                Text(
                  'Activez la localisation',
                  textAlign: TextAlign.center,
                  style: Typographie.echelle.headlineLarge,
                ),
                const SizedBox(height: Espaces.m),
                Text(
                  'Découvrez les produits et les boutiques les plus proches '
                  'de chez vous. La distance est calculée sur votre appareil : '
                  'votre position exacte n\'est jamais montrée aux vendeurs.',
                  textAlign: TextAlign.center,
                  style: Typographie.echelle.bodyMedium,
                ),

                const Spacer(flex: 3),

                BoutonPrincipal(
                  libelle: 'Activer la localisation',
                  icone: Symboles.myLocation,
                  enChargement: localisation.enCours,
                  onPressed: _autoriser,
                ),
                const SizedBox(height: Espaces.m),
                TextButton(
                  onPressed: _choisirZone,
                  child: Text(
                    'Choisir ma zone manuellement',
                    style: Typographie.echelle.labelLarge?.copyWith(
                      color: Couleurs.encre,
                    ),
                  ),
                ),
                const SizedBox(height: Espaces.l),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Repère de localisation posé sur ses ondes concentriques.
class _PastilleLocalisation extends StatelessWidget {
  const _PastilleLocalisation();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      width: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final (index, taille) in [230.0, 170.0, 110.0].indexed)
            Container(
              height: taille,
              width: taille,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Couleurs.orange.withValues(alpha: 0.04 + index * 0.025),
              ),
            ),
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              color: Couleurs.noir,
              shape: BoxShape.circle,
              border: Border.all(color: Couleurs.blanc, width: 3),
            ),
            child: const Icon(Symboles.place, fill: 1, size: 30, color: Couleurs.orange),
          ),
        ],
      ),
    );
  }
}
