import 'package:geolocator/geolocator.dart';

import '../donnees/communes.dart';

/// Résultat d'une demande de localisation.
enum ResultatLocalisation {
  /// Position obtenue.
  obtenue,

  /// L'utilisateur a refusé l'autorisation.
  refusee,

  /// L'utilisateur a refusé définitivement : seul le réglage système peut
  /// revenir sur ce choix.
  refuseeDefinitivement,

  /// Le service de localisation de l'appareil est éteint.
  serviceEteint,

  /// Autorisation accordée, mais la position n'a pas pu être lue.
  echec,
}

/// Accès au GPS de l'appareil.
///
/// Le cahier des charges fait de la géolocalisation le moteur de découverte de
/// l'application, tout en interdisant qu'un refus bloque le parcours. Ce
/// service se contente donc de rapporter ce qui s'est passé : c'est au
/// contrôleur de décider du repli sur une commune choisie à la main.
class ServiceLocalisation {
  const ServiceLocalisation._();

  /// Demande l'autorisation puis lit la position courante.
  static Future<(ResultatLocalisation, Position?)> positionActuelle() async {
    final serviceActif = await Geolocator.isLocationServiceEnabled();
    if (!serviceActif) {
      return (ResultatLocalisation.serviceEteint, null);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return (ResultatLocalisation.refuseeDefinitivement, null);
    }
    if (permission == LocationPermission.denied) {
      return (ResultatLocalisation.refusee, null);
    }

    try {
      // Précision moyenne volontairement : une précision maximale coûte du
      // temps et de la batterie pour un affichage au dixième de kilomètre.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return (ResultatLocalisation.obtenue, position);
    } catch (_) {
      // Délai dépassé, ou GPS indisponible malgré l'autorisation : on tente la
      // dernière position connue avant d'abandonner.
      try {
        final derniere = await Geolocator.getLastKnownPosition();
        if (derniere != null) {
          return (ResultatLocalisation.obtenue, derniere);
        }
      } catch (_) {
        // Ignoré : le repli manuel prend le relais.
      }
      return (ResultatLocalisation.echec, null);
    }
  }

  /// Message expliquant un échec, à afficher tel quel à l'utilisateur.
  static String messagePour(ResultatLocalisation resultat) {
    return switch (resultat) {
      ResultatLocalisation.obtenue => '',
      ResultatLocalisation.refusee =>
        'Localisation refusée. Choisissez votre zone dans la liste.',
      ResultatLocalisation.refuseeDefinitivement =>
        'Localisation bloquée dans les réglages du téléphone. '
            'Vous pouvez choisir votre zone manuellement.',
      ResultatLocalisation.serviceEteint =>
        'La localisation est désactivée sur votre téléphone. '
            'Choisissez votre zone dans la liste.',
      ResultatLocalisation.echec =>
        'Position introuvable pour le moment. Choisissez votre zone.',
    };
  }

  /// Ouvre les réglages de l'application, pour revenir sur un refus définitif.
  static Future<bool> ouvrirReglages() => Geolocator.openAppSettings();

  /// Commune correspondant à une position.
  static Commune communePour(double latitude, double longitude) =>
      Communes.plusProche(latitude, longitude);
}
