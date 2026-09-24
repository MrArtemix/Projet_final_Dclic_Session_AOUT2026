import 'dart:math' as math;

/// Calcul des distances géographiques de l'application.
///
/// Le dossier de conception prévoyait de confier ce calcul à PostGIS, via
/// `ST_Distance` sur une base PostgreSQL. Cloud Firestore, retenu comme base de
/// l'application, n'offre pas d'opérateur géospatial équivalent : la distance
/// est donc calculée ici, côté application, par la formule de haversine.
///
/// Cette formule donne la distance orthodromique, c'est-à-dire la longueur de
/// l'arc de grand cercle entre deux points à la surface du globe. Elle assimile
/// la Terre à une sphère, ce qui introduit une erreur inférieure à un demi pour
/// cent : sur les quelques kilomètres qui séparent deux communes d'Abidjan,
/// l'écart se compte en mètres et reste sans effet sur l'affichage.
class Distance {
  const Distance._();

  /// Rayon moyen de la Terre, en kilomètres.
  static const double rayonTerreKm = 6371.0088;

  /// Distance en kilomètres entre deux points repérés par leur latitude et
  /// leur longitude, exprimées en degrés décimaux.
  ///
  /// ```dart
  /// // Du Plateau à Cocody, environ quatre kilomètres.
  /// Distance.entre(5.3200, -4.0200, 5.3600, -3.9800);
  /// ```
  static double entre(
    double latitudeA,
    double longitudeA,
    double latitudeB,
    double longitudeB,
  ) {
    final phiA = _enRadians(latitudeA);
    final phiB = _enRadians(latitudeB);
    final deltaPhi = _enRadians(latitudeB - latitudeA);
    final deltaLambda = _enRadians(longitudeB - longitudeA);

    // a est le carré de la moitié de la corde entre les deux points.
    final a = math.pow(math.sin(deltaPhi / 2), 2) +
        math.cos(phiA) * math.cos(phiB) * math.pow(math.sin(deltaLambda / 2), 2);

    // c est l'angle au centre, en radians.
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return rayonTerreKm * c;
  }

  /// Mise en forme d'une distance pour l'affichage sur une annonce.
  ///
  /// Les maquettes montrent « A 2km » sous chaque produit. En dessous d'un
  /// kilomètre la valeur passe en mètres, arrondie à la centaine : une
  /// précision au mètre n'aurait aucun sens pour une position GPS de téléphone.
  static String formater(double distanceKm) {
    if (distanceKm < 0.1) {
      return 'Tout près';
    }
    if (distanceKm < 1) {
      final metres = (distanceKm * 1000 / 100).round() * 100;
      return 'À ${metres}m';
    }
    if (distanceKm < 10) {
      final arrondi = (distanceKm * 10).round() / 10;
      // « A 2km » plutôt que « A 2.0km » lorsque la décimale est nulle.
      final texte = arrondi == arrondi.roundToDouble()
          ? arrondi.round().toString()
          : arrondi.toString();
      return 'À ${texte}km';
    }
    return 'À ${distanceKm.round()}km';
  }

  static double _enRadians(double degres) => degres * math.pi / 180;
}
