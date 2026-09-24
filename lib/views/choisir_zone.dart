import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/localisation_controller.dart';
import '../donnees/communes.dart';
import '../theme/couleurs.dart';
import '../theme/dimensions.dart';
import '../theme/symboles.dart';
import '../theme/typographie.dart';
import '../widgets/communs/boutons.dart';
import '../widgets/communs/champs.dart';
import '../widgets/communs/etats.dart';
import '../widgets/communs/fond_texture.dart';
import '../widgets/metier/carte_zone.dart';
import 'accueil.dart';

/// Sélection manuelle d'une zone.
///
/// C'est le recours prévu lorsque la géolocalisation est refusée ou
/// indisponible. L'écran reste utilisable en toute circonstance : il ne dépend
/// ni du GPS, ni du réseau.
class ChoisirZone extends StatefulWidget {
  const ChoisirZone({super.key, this.remplaceLePrecedent = true});

  /// À vrai, valider remplace toute la pile et ouvre l'accueil. À faux, l'écran
  /// se referme simplement, cas d'un changement de zone depuis l'accueil.
  final bool remplaceLePrecedent;

  @override
  State<ChoisirZone> createState() => _ChoisirZoneState();
}

class _ChoisirZoneState extends State<ChoisirZone> {
  final _recherche = TextEditingController();
  List<Commune> _resultats = Communes.populaires;
  Commune? _choisie;
  bool _rechercheEnCours = false;

  @override
  void initState() {
    super.initState();
    _choisie = context.read<LocalisationController>().commune;
  }

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  void _filtrer(String saisie) {
    setState(() {
      _rechercheEnCours = saisie.trim().isNotEmpty;
      _resultats =
          _rechercheEnCours ? Communes.rechercher(saisie) : Communes.populaires;
    });
  }

  Future<void> _utiliserPositionActuelle() async {
    final localisation = context.read<LocalisationController>();
    final obtenue = await localisation.localiser();

    if (!mounted) return;

    if (obtenue) {
      setState(() => _choisie = localisation.commune);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localisation.message)),
      );
    }
  }

  Future<void> _confirmer() async {
    final commune = _choisie;
    if (commune == null) return;

    final localisation = context.read<LocalisationController>();
    localisation.choisirCommune(commune);

    await context.read<AuthController>().memoriserPosition(
          latitude: commune.latitude,
          longitude: commune.longitude,
          commune: commune.nom,
        );

    if (!mounted) return;

    if (widget.remplaceLePrecedent) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const Accueil()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localisation = context.watch<LocalisationController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Choisir ma zone'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Symboles.arrowBack),
        ),
      ),
      body: FondTexture(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Espaces.l,
                Espaces.s,
                Espaces.l,
                Espaces.l,
              ),
              child: Column(
                children: [
                  BarreRecherche(
                    controleur: _recherche,
                    indication: 'Rechercher une ville, une commune...',
                    onChange: _filtrer,
                  ),
                  const SizedBox(height: Espaces.l),
                  CarteZone(
                    // Sans commune choisie, la carte s'ouvre sur le Plateau,
                    // centre d'Abidjan et repère commun à tous les quartiers.
                    nomZone: _choisie?.nom ?? 'Abidjan',
                    latitude: _choisie?.latitude ?? 5.3253,
                    longitude: _choisie?.longitude ?? -4.0227,
                    rayonKm: 5,
                  ),
                  const SizedBox(height: Espaces.l),
                  BoutonSecondaire(
                    libelle: 'Utiliser ma position actuelle',
                    icone: Symboles.myLocation,
                    onPressed:
                        localisation.enCours ? null : _utiliserPositionActuelle,
                  ),
                ],
              ),
            ),

            Padding(
              padding: Espaces.ecran,
              child: Row(
                children: [
                  Text(
                    _rechercheEnCours
                        ? '${_resultats.length} RÉSULTATS'
                        : 'COMMUNES POPULAIRES',
                    style: Typographie.sectionCapitales,
                  ),
                  const Spacer(),
                  if (!_rechercheEnCours)
                    TextButton(
                      onPressed: () => setState(() {
                        _resultats = Communes.toutes;
                        _rechercheEnCours = true;
                      }),
                      child: const Text('Tout voir'),
                    ),
                ],
              ),
            ),

            Expanded(
              child: _resultats.isEmpty
                  ? EtatVide(
                      icone: Symboles.locationOff,
                      titre: 'Aucune zone trouvée',
                      message:
                          'Aucune commune ne correspond à « ${_recherche.text} ». '
                          'Vérifiez l\'orthographe ou parcourez la liste.',
                      libelleAction: 'Voir toutes les zones',
                      onAction: () {
                        _recherche.clear();
                        _filtrer('');
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Espaces.l,
                      ),
                      itemCount: _resultats.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (context, index) {
                        final commune = _resultats[index];
                        return _LigneCommune(
                          commune: commune,
                          choisie: commune.nom == _choisie?.nom,
                          onTap: () => setState(() => _choisie = commune),
                        );
                      },
                    ),
            ),

            BarreAction(
              child: BoutonPrincipal(
                libelle: _choisie == null
                    ? 'Choisissez une zone'
                    : 'Confirmer, ${_choisie!.nom}',
                onPressed: _choisie == null ? null : _confirmer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Une commune dans la liste.
class _LigneCommune extends StatelessWidget {
  const _LigneCommune({
    required this.commune,
    required this.choisie,
    required this.onTap,
  });

  final Commune commune;
  final bool choisie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Symboles.place,
        fill: 1,
        size: 20,
        color: choisie ? Couleurs.orangeVif : Couleurs.orange,
      ),
      title: Text(
        commune.nom,
        style: Typographie.echelle.titleMedium?.copyWith(
          fontWeight: choisie ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      subtitle: commune.ville == commune.nom ? null : Text(commune.ville),
      trailing: choisie
          ? const Icon(Symboles.checkCircle, fill: 1, size: 20, color: Couleurs.orange)
          : const Icon(
              Symboles.chevronRight,
              size: 20,
              color: Couleurs.encrePale,
            ),
    );
  }
}
