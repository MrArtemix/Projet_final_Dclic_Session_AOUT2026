import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/couleurs.dart';
import '../theme/dimensions.dart';
import '../theme/formes.dart';
import '../theme/symboles.dart';
import '../theme/typographie.dart';
import '../widgets/communs/boutons.dart';
import '../widgets/communs/fond_texture.dart';
import '../widgets/communs/logo.dart';
import 'connexion.dart';
import 'inscription.dart';

/// Une étape de la présentation.
class _Etape {
  const _Etape({
    required this.titre,
    required this.complement,
    required this.texte,
    required this.icone,
  });

  final String titre;
  final String complement;
  final String texte;
  final IconData icone;
}

/// Présentation de la proposition de valeur, puis entrée dans l'application.
///
/// Les trois arguments repris ici sont ceux du cahier des charges : un marché
/// connecté, la proximité géographique, la négociation en direct. La quatrième
/// page ouvre sur la création de compte ou la connexion, le compteur de
/// points en bas suit donc bien quatre étapes, comme sur les maquettes.
class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pages = PageController();
  int _index = 0;

  static const List<_Etape> _etapes = [
    _Etape(
      titre: 'Connecter le marché africain',
      complement: 'technologique',
      texte:
          'Un marché technologique africain digitalisé, qui réunit sur un même '
          'espace boutiques enregistrées et vendeurs de quartier.',
      icone: Symboles.hub,
    ),
    _Etape(
      titre: 'Trouvez des matériaux technologiques',
      complement: 'près de chez vous',
      texte:
          'Les annonces sont classées par proximité : vous voyez d\'abord ce '
          'qui se vend à quelques kilomètres, sans vous déplacer.',
      icone: Symboles.place,
    ),
    _Etape(
      titre: 'Négociez les prix de vos matériaux',
      complement: 'en direct',
      texte:
          'Discutez avec le vendeur, proposez votre prix, recevez une '
          'contre-offre. La négociation se fait dans l\'application.',
      icone: Symboles.forum,
    ),
  ];

  bool get _surDerniere => _index == _etapes.length;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _allerA(int index) => _pages.animateToPage(
        index,
        duration: Mouvement.normal,
        curve: Mouvement.courbe,
      );

  void _ouvrir(Widget ecran) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ecran),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.nuit,
      body: FondNuit(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pages,
                  onPageChanged: (index) => setState(() => _index = index),
                  children: [
                    for (final etape in _etapes) _PageEtape(etape: etape),
                    _PageEntree(
                      onCreerCompte: () => _ouvrir(const Inscription()),
                      onSeConnecter: () => _ouvrir(const Connexion()),
                    ),
                  ],
                ),
              ),
              _Pagination(index: _index, total: _etapes.length + 1),
              const SizedBox(height: Espaces.m),
              if (!_surDerniere) _BarreNavigation(
                index: _index,
                onPrecedent: () => _allerA(_index - 1),
                onSuivant: () => _allerA(_index + 1),
              ) else const SizedBox(height: Tailles.bouton),
              const SizedBox(height: Espaces.s),
            ],
          ),
        ),
      ),
    );
  }
}

/// Une page de présentation : illustration, titre, promesse.
class _PageEtape extends StatelessWidget {
  const _PageEtape({required this.etape});

  final _Etape etape;

  @override
  Widget build(BuildContext context) {
    // L'illustration suit la hauteur de l'appareil. Fixée à 190, elle ne
    // laissait plus la place au texte sous les 570 points de haut, et la
    // colonne débordait de l'écran.
    final cote = (MediaQuery.sizeOf(context).height * 0.26).clamp(130.0, 190.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Espaces.xl),
      child: Column(
        children: [
          const Spacer(flex: 2),
          HaloOrange(
            intensite: 0.16,
            child: Container(
              height: cote,
              width: cote,
              decoration: BoxDecoration(
                color: Couleurs.surfaceNuit,
                borderRadius: Coupes.feuille,
                border: Border.all(color: Couleurs.filetNuit),
              ),
              child: Icon(
                etape.icone,
                size: cote * 0.36,
                color: Couleurs.orange,
              ),
            ),
          )
              .animate(key: ValueKey(etape.titre))
              .fadeIn(duration: Mouvement.ample)
              .scale(begin: const Offset(0.94, 0.94), end: const Offset(1, 1)),
          const Spacer(),
          Text(
            etape.titre.toUpperCase(),
            textAlign: TextAlign.center,
            style: Typographie.echelle.displayMedium?.copyWith(
              fontSize: 25,
              color: Couleurs.encreInverse,
            ),
          ),
          const SizedBox(height: Espaces.s),
          Text(
            etape.complement.toUpperCase(),
            textAlign: TextAlign.center,
            style: Typographie.echelle.titleLarge?.copyWith(
              color: Couleurs.orange,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: Espaces.xl),
          Text(
            etape.texte,
            textAlign: TextAlign.center,
            style: Typographie.echelle.bodyMedium?.copyWith(
              color: Couleurs.encreInverseDouce,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

/// Dernière page : créer un compte ou se connecter.
class _PageEntree extends StatelessWidget {
  const _PageEntree({required this.onCreerCompte, required this.onSeConnecter});

  final VoidCallback onCreerCompte;
  final VoidCallback onSeConnecter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Espaces.xl),
      child: Column(
        children: [
          const Spacer(flex: 2),
          LogoMekano(
            taille: LogoMekano.tailleDeploye(context) * 0.9,
            nomEnColonne: true,
            surFondSombre: true,
            constellation: true,
          ),
          const Spacer(),
          Text(
            'Commencez maintenant',
            textAlign: TextAlign.center,
            style: Typographie.echelle.displayMedium?.copyWith(
              fontSize: 26,
              color: Couleurs.encreInverse,
            ),
          ),
          const SizedBox(height: Espaces.m),
          Text(
            'Créez votre compte en quelques secondes. Aucun document n\'est '
            'demandé pour vendre.',
            textAlign: TextAlign.center,
            style: Typographie.echelle.bodyMedium?.copyWith(
              color: Couleurs.encreInverseDouce,
            ),
          ),
          const Spacer(),
          BoutonAccentue(libelle: 'Créer un compte', onPressed: onCreerCompte),
          const SizedBox(height: Espaces.m),
          // Sur du noir, la variante atténuée de l'orange vire au terne : la
          // seconde action passe au contour clair, qui garde son rang sans
          // rivaliser avec la première.
          BoutonSecondaire(
            libelle: 'Se connecter',
            surFondSombre: true,
            onPressed: onSeConnecter,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

/// Points d'avancement, sous les pages.
class _Pagination extends StatelessWidget {
  const _Pagination({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (position) {
        final actif = position == index;
        return AnimatedContainer(
          duration: Mouvement.rapide,
          curve: Mouvement.courbe,
          margin: const EdgeInsets.symmetric(horizontal: Espaces.xs),
          height: 7,
          width: actif ? 22 : 7,
          decoration: BoxDecoration(
            color: actif ? Couleurs.orange : Couleurs.filetNuit,
            borderRadius: Coupes.pastille,
          ),
        );
      }),
    );
  }
}

/// « Précédent » et « Suivant », en bas des pages de présentation.
class _BarreNavigation extends StatelessWidget {
  const _BarreNavigation({
    required this.index,
    required this.onPrecedent,
    required this.onSuivant,
  });

  final int index;
  final VoidCallback onPrecedent;
  final VoidCallback onSuivant;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Tailles.bouton,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Espaces.s),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (index > 0)
              TextButton.icon(
                onPressed: onPrecedent,
                style: TextButton.styleFrom(
                  foregroundColor: Couleurs.encreInverseDouce,
                ),
                icon: const Icon(Symboles.arrowBack, size: 18),
                label: const Text('Précédent'),
              )
            else
              const SizedBox.shrink(),
            TextButton(
              onPressed: onSuivant,
              style: TextButton.styleFrom(foregroundColor: Couleurs.orange),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Suivant'),
                  SizedBox(width: Espaces.xs),
                  Icon(Symboles.arrowForward, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
