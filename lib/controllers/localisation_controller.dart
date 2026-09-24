import 'package:flutter/foundation.dart';

import '../donnees/communes.dart';
import '../services/service_localisation.dart';
import '../utils/distance.dart';

/// Origine de la position retenue pour l'utilisateur.
enum OriginePosition {
  /// Aucune position : l'application n'a pas encore de repère.
  aucune,

  /// Position lue sur le GPS de l'appareil.
  gps,

  /// Commune choisie à la main dans la liste ou sur la carte.
  manuelle,
}

/// Position de l'utilisateur et découverte par proximité.
///
/// Ce contrôleur porte la règle centrale du cahier des charges : la
/// géolocalisation guide la découverte, mais son refus n'interrompt jamais le
/// parcours. Dès qu'une position est indisponible, l'application bascule sur
/// la sélection manuelle d'une commune, et tout le reste continue de
/// fonctionner à l'identique.
class LocalisationController extends ChangeNotifier {
  double? _latitude;
  double? _longitude;
  Commune? _commune;
  OriginePosition _origine = OriginePosition.aucune;
  bool _enCours = false;
  String _message = '';

  double? get latitude => _latitude;
  double? get longitude => _longitude;

  /// Commune courante, déduite du GPS ou choisie par l'utilisateur.
  Commune? get commune => _commune;

  OriginePosition get origine => _origine;

  /// Vrai pendant l'interrogation du GPS.
  bool get enCours => _enCours;

  /// Dernier message d'explication, vide si tout s'est bien passé.
  String get message => _message;

  /// Vrai lorsqu'une position exploitable est disponible.
  bool get aUnePosition => _latitude != null && _longitude != null;

  /// Nom lisible de la zone courante, pour les en-têtes d'écran.
  String get libelleZone => _commune?.libelleComplet ?? 'Zone non définie';

  /// Tente d'obtenir la position par le GPS.
  ///
  /// Retourne vrai en cas de succès. En cas d'échec, [message] explique la
  /// raison et l'écran appelant propose la sélection manuelle.
  Future<bool> localiser() async {
    _enCours = true;
    _message = '';
    notifyListeners();

    final (resultat, position) = await ServiceLocalisation.positionActuelle();

    if (resultat == ResultatLocalisation.obtenue && position != null) {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _commune = ServiceLocalisation.communePour(
        position.latitude,
        position.longitude,
      );
      _origine = OriginePosition.gps;
      _message = '';
    } else {
      _message = ServiceLocalisation.messagePour(resultat);
    }

    _enCours = false;
    notifyListeners();
    return _origine == OriginePosition.gps;
  }

  /// Retient la commune choisie à la main.
  void choisirCommune(Commune commune) {
    _commune = commune;
    _latitude = commune.latitude;
    _longitude = commune.longitude;
    _origine = OriginePosition.manuelle;
    _message = '';
    notifyListeners();
  }

  /// Position de repli, utilisée tant que l'utilisateur n'a rien choisi.
  ///
  /// Elle permet d'afficher des distances cohérentes dès le premier écran,
  /// plutôt qu'une liste sans repère de proximité.
  void appliquerPositionParDefaut() {
    if (aUnePosition) return;
    choisirCommune(Communes.parDefaut);
    _origine = OriginePosition.aucune;
    notifyListeners();
  }

  /// Distance en kilomètres jusqu'à un point, ou `null` sans position connue.
  double? distanceVers(double latitude, double longitude) {
    if (!aUnePosition) return null;
    return Distance.entre(_latitude!, _longitude!, latitude, longitude);
  }

  /// Ouvre les réglages système, après un refus définitif.
  Future<void> ouvrirReglages() => ServiceLocalisation.ouvrirReglages();
}
