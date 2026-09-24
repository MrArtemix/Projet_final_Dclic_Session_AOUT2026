import 'package:flutter/widgets.dart';

/// Glyphes Material Symbols Rounded embarqués par l'application.
///
/// Les `Icons` du SDK datent de 2018 : leur dessin trahit l'âge d'une
/// interface. La police retenue ici est la génération courante du catalogue
/// Material, dans sa variante arrondie, réduite aux seuls glyphes utilisés,
/// une soixantaine de kilo-octets, ce qui reste tenable pour le téléphone
/// d'entrée de gamme visé par le cahier des charges.
///
/// Elle est **variable** : le remplissage et l'épaisseur du trait se pilotent
/// à l'affichage, sans glyphe supplémentaire. Une icône pleine et son contour
/// sont donc le même symbole, posé avec un `fill` différent :
///
/// ```dart
/// Icon(Symboles.favorite)          // contour
/// Icon(Symboles.favorite, fill: 1) // plein
/// ```
///
/// Les noms restent ceux du catalogue Material : ils désignent un glyphe et
/// non une notion métier, et doivent pouvoir être retrouvés tels quels sur
/// fonts.google.com/icons.
///
/// Fichier engendré par `tool/preparer_symboles.py` : toute retouche manuelle
/// sera perdue à la prochaine exécution.
class Symboles {
  const Symboles._();

  /// Famille déclarée au `pubspec.yaml`.
  static const String famille = 'Symboles';


  static const IconData add = IconData(0xe145, fontFamily: famille);
  static const IconData arrowBack = IconData(0xe5c4, fontFamily: famille);
  static const IconData arrowForward = IconData(0xe5c8, fontFamily: famille);
  static const IconData batteryChargingFull = IconData(0xe1a3, fontFamily: famille);
  static const IconData business = IconData(0xe7ee, fontFamily: famille);
  static const IconData cable = IconData(0xefe6, fontFamily: famille);
  static const IconData call = IconData(0xf0d4, fontFamily: famille);
  static const IconData category = IconData(0xe72c, fontFamily: famille);
  static const IconData check = IconData(0xe668, fontFamily: famille);
  static const IconData checkCircle = IconData(0xf0be, fontFamily: famille);
  static const IconData chevronRight = IconData(0xe5cc, fontFamily: famille);
  static const IconData close = IconData(0xe5cd, fontFamily: famille);
  static const IconData cloudOff = IconData(0xe2c1, fontFamily: famille);
  static const IconData cloudUpload = IconData(0xe2c3, fontFamily: famille);
  static const IconData creditCard = IconData(0xe8a1, fontFamily: famille);
  static const IconData darkMode = IconData(0xe51c, fontFamily: famille);
  static const IconData description = IconData(0xe873, fontFamily: famille);
  static const IconData directions = IconData(0xe52e, fontFamily: famille);
  static const IconData edit = IconData(0xf097, fontFamily: famille);
  static const IconData error = IconData(0xf8b6, fontFamily: famille);
  static const IconData favorite = IconData(0xe87e, fontFamily: famille);
  static const IconData flag = IconData(0xf0c6, fontFamily: famille);
  static const IconData forum = IconData(0xe8af, fontFamily: famille);
  static const IconData gridView = IconData(0xe9b0, fontFamily: famille);
  static const IconData handshake = IconData(0xebcb, fontFamily: famille);
  static const IconData handyman = IconData(0xf10b, fontFamily: famille);
  static const IconData headphones = IconData(0xf01f, fontFamily: famille);
  static const IconData help = IconData(0xe8fd, fontFamily: famille);
  static const IconData hub = IconData(0xe9f4, fontFamily: famille);
  static const IconData image = IconData(0xe3f4, fontFamily: famille);
  static const IconData info = IconData(0xe88e, fontFamily: famille);
  static const IconData inventory2 = IconData(0xe1a1, fontFamily: famille);
  static const IconData keyboardArrowDown = IconData(0xe313, fontFamily: famille);
  static const IconData language = IconData(0xea07, fontFamily: famille);
  static const IconData laptopMac = IconData(0xe320, fontFamily: famille);
  static const IconData localOffer = IconData(0xf05b, fontFamily: famille);
  static const IconData localShipping = IconData(0xe558, fontFamily: famille);
  static const IconData locationOff = IconData(0xe0c7, fontFamily: famille);
  static const IconData logout = IconData(0xe9ba, fontFamily: famille);
  static const IconData memory = IconData(0xe322, fontFamily: famille);
  static const IconData monitor = IconData(0xef5b, fontFamily: famille);
  static const IconData moreVert = IconData(0xe5d4, fontFamily: famille);
  static const IconData myLocation = IconData(0xe55c, fontFamily: famille);
  static const IconData notifications = IconData(0xe7f5, fontFamily: famille);
  static const IconData person = IconData(0xf0d3, fontFamily: famille);
  static const IconData photoCamera = IconData(0xe412, fontFamily: famille);
  static const IconData place = IconData(0xf1db, fontFamily: famille);
  static const IconData print = IconData(0xe8ad, fontFamily: famille);
  static const IconData rateReview = IconData(0xe560, fontFamily: famille);
  static const IconData remove = IconData(0xe15b, fontFamily: famille);
  static const IconData reply = IconData(0xe15e, fontFamily: famille);
  static const IconData router = IconData(0xe328, fontFamily: famille);
  static const IconData search = IconData(0xef7a, fontFamily: famille);
  static const IconData searchOff = IconData(0xea76, fontFamily: famille);
  static const IconData send = IconData(0xe163, fontFamily: famille);
  static const IconData settings = IconData(0xe8b8, fontFamily: famille);
  static const IconData share = IconData(0xe80d, fontFamily: famille);
  static const IconData shoppingBag = IconData(0xf1cc, fontFamily: famille);
  static const IconData shoppingCart = IconData(0xe8cc, fontFamily: famille);
  static const IconData smartphone = IconData(0xe7ba, fontFamily: famille);
  static const IconData star = IconData(0xf09a, fontFamily: famille);
  static const IconData starHalf = IconData(0xe839, fontFamily: famille);
  static const IconData storefront = IconData(0xea12, fontFamily: famille);
  static const IconData swapHoriz = IconData(0xe8d4, fontFamily: famille);
  static const IconData verified = IconData(0xef76, fontFamily: famille);
  static const IconData visibility = IconData(0xe8f4, fontFamily: famille);
  static const IconData visibilityOff = IconData(0xe8f5, fontFamily: famille);
  static const IconData wifiOff = IconData(0xe648, fontFamily: famille);
}
