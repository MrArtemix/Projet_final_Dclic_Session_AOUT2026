import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'motif_reseau.dart';

import '../../theme/couleurs.dart';

/// Ambiance du fond d'écran.
enum AmbianceFond {
  /// Blanc neutre : écrans de liste, de formulaire et de réglages.
  neutre,

  /// Blanc réchauffé par un halo orange diffus. Réservé aux écrans qui
  /// mettent une zone en valeur : onboarding, image produit, carte de zone.
  chaude,
}

/// Fond blanc texturé de l'application.
///
/// La charte demande un blanc qui ne soit pas plat. Quatre couches se
/// superposent, de la plus lointaine à la plus proche :
///
/// 1. un dégradé à quatre arrêts, dont les extrémités ne s'écartent que de
///    deux pour cent : il donne une direction à la lumière sans qu'aucune
///    bande ne soit perceptible. Quatre arrêts plutôt que trois, car un
///    dégradé linéaire sur un écran de deux mille pixels laisse voir ses
///    paliers dès que l'écart entre deux arrêts dépasse un pour cent ;
/// 2. un vignettage périphérique, à trois pour cent d'opacité dans les angles
///    seulement : il recentre le regard sur le contenu. C'est la couche qui
///    fait la différence sur un grand écran, et celle que l'on ne voit pas ;
/// 3. un halo orange large et très dilué, en ambiance chaude ;
/// 4. un grain, tuilé à partir d'une texture de soixante-quatre pixels de
///    côté, qui casse la platitude du blanc.
///
/// Le grain est calibré sur la densité de l'écran. À densité double, les
/// mêmes cinq pour cent qui disparaissent sur un écran triple densité
/// deviennent un bruit visible : l'opacité descend donc avec la densité.
///
/// Le coût de rendu est tenu : la texture pèse trois kilo-octets, elle est
/// dessinée par répétition sans redimensionnement, et l'ensemble est isolé
/// sous un [RepaintBoundary] pour ne jamais être redessiné lorsque le contenu
/// change. Ce point compte : le cahier des charges vise des appareils Android
/// d'entrée de gamme.
class FondTexture extends StatelessWidget {
  const FondTexture({
    super.key,
    required this.child,
    this.ambiance = AmbianceFond.neutre,
    this.intensiteGrain,
    this.vignettage = true,
  });

  /// Contenu posé sur le fond.
  final Widget child;

  /// Ambiance retenue pour l'écran.
  final AmbianceFond ambiance;

  /// Opacité du grain.
  ///
  /// Laissée nulle, elle se déduit de la densité de l'écran. La valeur reste
  /// sous le seuil de perception consciente : on ne voit pas le grain, on voit
  /// une surface moins plate.
  final double? intensiteGrain;

  /// Assombrissement des angles. À couper sur un écran dont le contenu va
  /// jusqu'aux bords, une galerie photo par exemple.
  final bool vignettage;

  /// Les quatre arrêts du dégradé, par ambiance.
  static const Map<AmbianceFond, List<Color>> _degrades = {
    AmbianceFond.neutre: [
      Color(0xFFFDFDFC),
      Color(0xFFFCFBF9),
      Color(0xFFFBFAF7),
      Color(0xFFFAF8F5),
    ],
    AmbianceFond.chaude: [
      Color(0xFFFFFEFD),
      Color(0xFFFEFCFA),
      Color(0xFFFCFAF6),
      Color(0xFFFBF7F2),
    ],
  };

  /// Opacité du grain selon la densité de l'écran.
  static double _grainSelonDensite(double densite) {
    if (densite >= 3) return 0.05;
    if (densite >= 2) return 0.035;
    return 0.022;
  }

  @override
  Widget build(BuildContext context) {
    final chaude = ambiance == AmbianceFond.chaude;
    final grain =
        intensiteGrain ?? _grainSelonDensite(MediaQuery.devicePixelRatioOf(context));

    return Stack(
      children: [
        // Couches décoratives : jamais reconstruites avec le contenu.
        Positioned.fill(
          child: RepaintBoundary(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: _degrades[ambiance]!,
                    stops: const [0, 0.35, 0.72, 1],
                  ),
                ),
                child: Stack(
                  children: [
                    if (chaude)
                      const Positioned(
                        top: -180,
                        left: -60,
                        right: -60,
                        height: 440,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [Color(0x0FF26B0F), Color(0x00F26B0F)],
                            ),
                          ),
                        ),
                      ),
                    if (vignettage)
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              // Le rayon d'un dégradé radial se mesure sur la
                              // plus grande dimension : sur un écran deux fois
                              // plus haut que large, un rayon d'une unité
                              // laisserait une zone claire trop étroite et
                              // grisaillerait toute la largeur. D'où un rayon
                              // large et une course qui ne commence qu'aux
                              // trois quarts.
                              radius: 1.4,
                              stops: [0.78, 1],
                              colors: [Color(0x00140E08), Color(0x07140E08)],
                            ),
                          ),
                        ),
                      ),
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/grain.png',
                        repeat: ImageRepeat.repeat,
                        // Traitée comme une image triple densité : le grain
                        // reste fin sur les écrans à forte résolution.
                        scale: 3,
                        opacity: AlwaysStoppedAnimation<double>(grain),
                        filterQuality: FilterQuality.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Fond de nuit, pendant sombre de [FondTexture].
///
/// L'entrée dans l'application, chargement puis présentation, se fait sur du
/// noir, et le passage au clair ne survient qu'une fois l'utilisateur arrivé
/// dans le catalogue. Cette bascule vaut mise en scène : le produit s'annonce
/// sur une surface pleine, puis s'efface devant les annonces.
///
/// Trois couches, comme pour son pendant clair : un dégradé très long, le
/// réseau de la marque tracé en grand, et le même grain, qui, sur du noir,
/// évite au dégradé de laisser voir ses paliers.
class FondNuit extends StatelessWidget {
  const FondNuit({
    super.key,
    required this.child,
    this.motif = true,
    this.intensiteGrain,
  });

  final Widget child;

  /// Trace le réseau de la marque derrière le contenu.
  final bool motif;

  final double? intensiteGrain;

  @override
  Widget build(BuildContext context) {
    final grain =
        intensiteGrain ?? FondTexture._grainSelonDensite(
          MediaQuery.devicePixelRatioOf(context),
        );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Couleurs.nuitHaute,
                        Couleurs.nuit,
                        Color(0xFF080706),
                      ],
                      stops: [0, 0.55, 1],
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (motif)
                        const Positioned(
                          top: -60,
                          left: -80,
                          right: -80,
                          height: 620,
                          child: MotifReseau(
                            graine: 20260918,
                            surSombre: true,
                            densite: 11,
                            intensite: 0.5,
                          ),
                        ),
                      // Halo orange bas, qui empêche le noir de s'aplatir dans
                      // la moitié inférieure de l'écran.
                      const Positioned(
                        bottom: -220,
                        left: -60,
                        right: -60,
                        height: 520,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [Color(0x1FF26B0F), Color(0x00F26B0F)],
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/grain.png',
                          repeat: ImageRepeat.repeat,
                          scale: 3,
                          opacity: AlwaysStoppedAnimation<double>(grain * 1.6),
                          filterQuality: FilterQuality.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Halo orange diffus, à poser derrière un élément à mettre en valeur.
///
/// Sert notamment derrière l'image d'une fiche produit et derrière la carte de
/// l'écran de sélection de zone, où les maquettes montrent un fond légèrement
/// réchauffé.
class HaloOrange extends StatelessWidget {
  const HaloOrange({
    super.key,
    required this.child,
    this.intensite = 0.09,
    this.alignement = Alignment.center,
  });

  final Widget child;

  /// Opacité du centre du halo.
  final double intensite;

  /// Point d'où rayonne le halo. Décentré, il suggère une source de lumière
  /// plutôt qu'un projecteur.
  final Alignment alignement;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: alignement,
                  colors: [
                    Couleurs.orange.withValues(alpha: intensite),
                    Couleurs.orange.withValues(alpha: intensite * 0.35),
                    Couleurs.orange.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.45, 1],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
