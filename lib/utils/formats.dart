import 'package:intl/intl.dart';

/// Mises en forme communes à l'application, en français.
class Formats {
  const Formats._();

  /// Devise du marché visé : le franc CFA d'Afrique de l'Ouest.
  ///
  /// Les maquettes portaient un symbole dollar, hérité de leur gabarit. Le
  /// cahier des charges vise Abidjan : l'application affiche donc des francs
  /// CFA. Le symbole reste centralisé ici, ce qui permettra d'en gérer
  /// plusieurs à la version trois sans reprendre les écrans un à un.
  static const String symboleDevise = 'FCFA';

  static final NumberFormat _montant = NumberFormat.decimalPattern('fr_FR');

  /// Met en forme un montant : `45000` devient `45 000 FCFA`.
  ///
  /// L'usage local place la devise **après** le nombre. L'espace qui l'en
  /// sépare est insécable : un prix ne doit jamais se couper en fin de ligne.
  static String prix(num montant) => '${montantSeul(montant)}\u00A0$symboleDevise';

  /// Montant seul, sans devise : `45 000`.
  ///
  /// Sert aux affichages qui hiérarchisent le prix, la fiche produit en tête,
  /// où le nombre est posé en grand et la devise à côté, plus discrète.
  static String montantSeul(num montant) => _montant.format(montant.round());

  /// Note d'un vendeur, toujours avec une décimale : `4.5`.
  static String note(double valeur) => valeur.toStringAsFixed(1);

  /// Heure d'un message de conversation : `09:41`.
  static String heure(DateTime horodatage) =>
      DateFormat.Hm('fr_FR').format(horodatage);

  /// Date longue : `17 septembre 2026`.
  static String dateLongue(DateTime date) =>
      DateFormat.yMMMMd('fr_FR').format(date);

  /// Ancienneté lisible d'un message ou d'une annonce.
  ///
  /// Au delà d'une semaine la date exacte est préférée : « il y a 23 jours »
  /// se lit moins bien qu'une date.
  static String depuis(DateTime horodatage) {
    final ecart = DateTime.now().difference(horodatage);

    if (ecart.inMinutes < 1) return 'À l\'instant';
    if (ecart.inMinutes < 60) return 'Il y a ${ecart.inMinutes} min';
    if (ecart.inHours < 24) return 'Il y a ${ecart.inHours} h';
    if (ecart.inDays == 1) return 'Hier';
    if (ecart.inDays < 7) return 'Il y a ${ecart.inDays} jours';
    return dateLongue(horodatage);
  }

  /// Compteur abrégé des statistiques d'une boutique : `1.2k`, `3.4k`.
  static String compteurAbrege(int valeur) {
    if (valeur < 1000) return valeur.toString();
    final milliers = valeur / 1000;
    if (milliers < 10) {
      final arrondi = (milliers * 10).round() / 10;
      return '${arrondi.toStringAsFixed(1)}k';
    }
    return '${milliers.round()}k';
  }
}
