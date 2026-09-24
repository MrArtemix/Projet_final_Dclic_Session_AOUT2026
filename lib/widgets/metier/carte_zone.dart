import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../theme/couleurs.dart';
import '../../theme/dimensions.dart';
import '../../theme/symboles.dart';
import '../../theme/typographie.dart';
import 'carte_stylisee.dart';

/// Carte de la zone choisie, sur fond OpenStreetMap.
///
/// Les tuiles viennent d'OpenStreetMap : contrairement à Google Maps ou
/// Mapbox, elles ne demandent ni clé d'interface de programmation, ni compte
/// de facturation. La contrepartie est qu'elles exigent le réseau — or le
/// cahier des charges demande un fonctionnement acceptable en connexion
/// instable. Dès qu'une tuile échoue, la [CarteStylisee] dessinée localement
/// reprend donc la place : l'écran ne montre jamais un cadre vide.
class CarteZone extends StatefulWidget {
  const CarteZone({
    super.key,
    required this.nomZone,
    required this.latitude,
    required this.longitude,
    this.hauteur = 200,
    this.rayonKm,
  });

  /// Nom de la zone, repris par la carte de repli comme germe de tracé.
  final String nomZone;

  final double latitude;
  final double longitude;
  final double hauteur;

  /// Rayon de recherche à matérialiser autour du repère.
  final double? rayonKm;

  @override
  State<CarteZone> createState() => _CarteZoneState();
}

class _CarteZoneState extends State<CarteZone> {
  /// Délai au-delà duquel une carte muette est considérée comme perdue.
  ///
  /// Un réseau coupé net provoque une erreur, que l'on sait intercepter ; un
  /// réseau très lent, lui, ne provoque rien du tout et laisserait un cadre
  /// gris indéfiniment. Ce délai tranche le second cas.
  static const _delaiDeGarde = Duration(seconds: 6);

  final MapController _carte = MapController();

  Timer? _garde;

  /// Passe à vrai dès qu'une tuile n'a pas pu être chargée, ou que le délai de
  /// garde s'est écoulé sans qu'aucune ne soit arrivée.
  bool _tuilesIndisponibles = false;

  /// Vrai dès qu'une seule tuile est affichée : la carte est alors vivante.
  bool _uneTuileAffichee = false;

  LatLng get _centre => LatLng(widget.latitude, widget.longitude);

  @override
  void initState() {
    super.initState();
    // Le minuteur s'exécute hors de toute phase de dessin : il peut basculer
    // l'affichage sans détour.
    _garde = Timer(_delaiDeGarde, () {
      if (!_uneTuileAffichee) _basculer();
    });
  }

  @override
  void dispose() {
    _garde?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(CarteZone ancienne) {
    super.didUpdateWidget(ancienne);

    // Changer de commune recentre la carte plutôt que de la reconstruire :
    // le déplacement reste lisible, et les tuiles déjà chargées sont gardées.
    if (ancienne.latitude != widget.latitude ||
        ancienne.longitude != widget.longitude) {
      _carte.move(_centre, _zoom);
    }
  }

  /// Niveau de zoom cadrant le rayon de recherche.
  double get _zoom => widget.rayonKm == null ? 13 : 12;

  /// Remplace le fond réel par la carte dessinée.
  void _basculer() {
    if (!mounted || _tuilesIndisponibles || _uneTuileAffichee) return;
    _garde?.cancel();
    setState(() => _tuilesIndisponibles = true);
  }

  /// Échec signalé par une tuile, donc en pleine phase de dessin : la bascule
  /// est repoussée à la fin de l'image, faute de quoi l'arbre serait
  /// reconstruit alors qu'il est en cours de peinture.
  void _signalerEchec() {
    if (_tuilesIndisponibles || _uneTuileAffichee) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _basculer());
  }

  @override
  Widget build(BuildContext context) {
    if (_tuilesIndisponibles) {
      return Stack(
        children: [
          CarteStylisee(
            nomZone: widget.nomZone,
            hauteur: widget.hauteur,
            rayonKm: widget.rayonKm,
          ),
          const Positioned(left: 8, bottom: 8, child: _MentionHorsLigne()),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.hauteur,
        width: double.infinity,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _carte,
              options: MapOptions(
                initialCenter: _centre,
                initialZoom: _zoom,
                // La carte est un aperçu posé dans une colonne : le zoom et le
                // déplacement suffisent, la rotation désorienterait sans
                // rendre service.
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom |
                      InteractiveFlag.drag |
                      InteractiveFlag.doubleTapZoom,
                ),
                backgroundColor: Couleurs.blancCreux,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  // Exigé par la politique d'usage des tuiles OpenStreetMap :
                  // le serveur doit pouvoir identifier l'application qui
                  // l'interroge.
                  userAgentPackageName: 'com.dclic.mekano_afrika',
                  errorTileCallback: (tuile, erreur, trace) =>
                      _signalerEchec(),
                  tileBuilder: (context, dessin, tuile) {
                    // `tileBuilder` passe ici pour toute tuile, y compris
                    // celles encore en vol : seule une image effectivement
                    // chargée, et sans erreur, prouve que le fond réel est
                    // arrivé et rend le délai de garde inutile.
                    if (!_uneTuileAffichee &&
                        tuile.loadFinishedAt != null &&
                        !tuile.loadError) {
                      _uneTuileAffichee = true;
                      _garde?.cancel();
                    }
                    return dessin;
                  },
                ),
                if (widget.rayonKm != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: _centre,
                        radius: widget.rayonKm! * 1000,
                        useRadiusInMeter: true,
                        color: Couleurs.orange.withValues(alpha: 0.14),
                        borderColor: Couleurs.orange,
                        borderStrokeWidth: 1.5,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _centre,
                      width: 48,
                      height: 48,
                      child: const _Repere(),
                    ),
                  ],
                ),
              ],
            ),
            // Mention obligatoire : les tuiles OpenStreetMap sont sous licence
            // ODbL, qui impose de citer la source à l'écran.
            const Positioned(right: 6, bottom: 6, child: _Attribution()),
          ],
        ),
      ),
    );
  }
}

/// Pastille noire marquant la zone, reprise du repère de la carte dessinée.
class _Repere extends StatelessWidget {
  const _Repere();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: Couleurs.noir,
          shape: BoxShape.circle,
          border: Border.all(color: Couleurs.blanc, width: 2.5),
        ),
        child: const Icon(
          Symboles.place,
          fill: 1,
          size: 20,
          color: Couleurs.orange,
        ),
      ),
    );
  }
}

/// Citation de la source des tuiles.
class _Attribution extends StatelessWidget {
  const _Attribution();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Couleurs.blanc.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Text(
          '© OpenStreetMap',
          style: Typographie.echelle.bodySmall?.copyWith(fontSize: 9),
        ),
      ),
    );
  }
}

/// Signale que le fond de carte réel n'a pas pu être chargé.
class _MentionHorsLigne extends StatelessWidget {
  const _MentionHorsLigne();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Couleurs.blanc.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(Rayons.s),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symboles.cloudOff, size: 12),
            const SizedBox(width: 4),
            Text(
              'Carte hors ligne',
              style: Typographie.echelle.bodySmall?.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
