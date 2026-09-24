/// Une zone géographique sélectionnable par l'utilisateur.
class Commune {
  const Commune({
    required this.nom,
    required this.latitude,
    required this.longitude,
    this.ville = 'Abidjan',
    this.populaire = false,
  });

  final String nom;
  final double latitude;
  final double longitude;
  final String ville;

  /// Mise en avant dans la liste « Communes populaires » de l'écran de
  /// sélection de zone.
  final bool populaire;

  String get libelleComplet => '$nom, $ville';
}

/// Communes couvertes par la version initiale de l'application.
///
/// Cette liste est le recours prévu par le cahier des charges lorsque la
/// géolocalisation est refusée ou indisponible : l'utilisateur choisit sa zone
/// à la main et le parcours se poursuit sans interruption. Les coordonnées
/// servent alors de position de référence pour le calcul des distances.
class Communes {
  const Communes._();

  static const List<Commune> toutes = [
    Commune(nom: 'Cocody', latitude: 5.3600, longitude: -3.9800, populaire: true),
    Commune(nom: 'Yopougon', latitude: 5.3364, longitude: -4.0705, populaire: true),
    Commune(nom: 'Marcory', latitude: 5.3000, longitude: -3.9833, populaire: true),
    Commune(nom: 'Plateau', latitude: 5.3253, longitude: -4.0227, populaire: true),
    Commune(nom: 'Abobo', latitude: 5.4200, longitude: -4.0200, populaire: true),
    Commune(nom: 'Adjamé', latitude: 5.3547, longitude: -4.0244),
    Commune(nom: 'Treichville', latitude: 5.2939, longitude: -4.0086),
    Commune(nom: 'Koumassi', latitude: 5.2919, longitude: -3.9450),
    Commune(nom: 'Port-Bouët', latitude: 5.2569, longitude: -3.9264),
    Commune(nom: 'Attécoubé', latitude: 5.3400, longitude: -4.0400),
    Commune(nom: 'Bingerville', latitude: 5.3550, longitude: -3.8850),
    Commune(nom: 'Anyama', latitude: 5.4947, longitude: -4.0517),
    Commune(nom: 'Songon', latitude: 5.3167, longitude: -4.2500),
    Commune(nom: 'Bouaké', latitude: 7.6900, longitude: -5.0300, ville: 'Bouaké'),
    Commune(nom: 'Yamoussoukro', latitude: 6.8276, longitude: -5.2893, ville: 'Yamoussoukro'),
    Commune(nom: 'San-Pédro', latitude: 4.7485, longitude: -6.6363, ville: 'San-Pédro'),
  ];

  /// Communes mises en avant sur l'écran de sélection de zone.
  static List<Commune> get populaires =>
      toutes.where((commune) => commune.populaire).toList();

  /// Recherche par nom, insensible à la casse et aux espaces superflus.
  static List<Commune> rechercher(String saisie) {
    final requete = saisie.trim().toLowerCase();
    if (requete.isEmpty) return toutes;
    return toutes
        .where((commune) =>
            commune.nom.toLowerCase().contains(requete) ||
            commune.ville.toLowerCase().contains(requete))
        .toList();
  }

  /// Commune retenue par défaut tant qu'aucune position n'est connue.
  static const Commune parDefaut = Commune(
    nom: 'Cocody',
    latitude: 5.3600,
    longitude: -3.9800,
    populaire: true,
  );

  /// Commune la plus proche d'une position donnée.
  ///
  /// Sert à nommer la zone de l'utilisateur après une localisation GPS : le
  /// cahier des charges demande d'afficher une commune, pas des coordonnées.
  static Commune plusProche(double latitude, double longitude) {
    var meilleure = toutes.first;
    var meilleurEcart = double.infinity;

    for (final commune in toutes) {
      // Comparaison au carré de l'écart : inutile de calculer une vraie
      // distance ici, seul le classement importe.
      final dLat = commune.latitude - latitude;
      final dLon = commune.longitude - longitude;
      final ecart = dLat * dLat + dLon * dLon;
      if (ecart < meilleurEcart) {
        meilleurEcart = ecart;
        meilleure = commune;
      }
    }
    return meilleure;
  }
}
