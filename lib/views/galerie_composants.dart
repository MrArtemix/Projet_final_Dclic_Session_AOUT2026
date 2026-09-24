import 'package:flutter/material.dart';

import '../donnees/jeu_demonstration.dart';
import '../models/message.dart';
import '../models/produit.dart';
import '../theme/couleurs.dart';
import '../theme/dimensions.dart';
import '../theme/formes.dart';
import '../theme/symboles.dart';
import '../theme/typographie.dart';
import '../utils/formats.dart';
import '../widgets/communs/boutons.dart';
import '../widgets/communs/champs.dart';
import '../widgets/communs/etats.dart';
import '../widgets/communs/fond_texture.dart';
import '../widgets/metier/cartes.dart';
import '../widgets/metier/indicateurs.dart';
import '../widgets/metier/negociation.dart';

/// Galerie des composants du design system.
///
/// Cet écran ne fait pas partie du parcours : il sert à vérifier d'un coup
/// d'œil que chaque composant rend correctement, teintes de blanc, grain,
/// hiérarchie du prix, règle d'emploi de l'orange et du noir, avant que les
/// écrans ne soient assemblés. Il fournit aussi une capture utile au rapport.
class GalerieComposants extends StatefulWidget {
  const GalerieComposants({super.key});

  @override
  State<GalerieComposants> createState() => _GalerieComposantsState();
}

class _GalerieComposantsState extends State<GalerieComposants> {
  int _quantite = 1;
  bool _favori = true;
  bool _suivie = false;
  bool _filtreActif = true;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final produit = JeuDemonstration.produits.first;
    final boutique = JeuDemonstration.boutiques.first;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FondTexture(
        ambiance: AmbianceFond.chaude,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              Espaces.l,
              Espaces.l,
              Espaces.l,
              Espaces.xxxl,
            ),
            children: [
              Text('Mekano Afrika', style: Typographie.echelle.displayMedium),
              const SizedBox(height: Espaces.xs),
              Text(
                'Galerie du design system, vérification du rendu',
                style: Typographie.echelle.bodyMedium,
              ),
              const SizedBox(height: Espaces.xxl),

              _Section('Palette'),
              const _NuancierBlancs(),
              const SizedBox(height: Espaces.m),
              const _NuancierAccents(),

              _Section('Typographie'),
              Text('Display 34', style: Typographie.echelle.displayLarge),
              Text('Titre de section', style: Typographie.echelle.titleLarge),
              Text('Titre de carte', style: Typographie.echelle.titleMedium),
              Text(
                'Paragraphe courant : la description d\'un produit se lit sur '
                'plusieurs lignes, en gris, avec un interligne aéré.',
                style: Typographie.echelle.bodyMedium,
              ),
              const SizedBox(height: Espaces.s),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(Formats.prix(45000), style: Typographie.prix),
                  const SizedBox(width: Espaces.s),
                  Text(Formats.prix(60000), style: Typographie.prixBarre),
                  const SizedBox(width: Espaces.s),
                  const BadgeReduction(pourcentage: 25),
                ],
              ),

              _Section('Actions'),
              BoutonPrincipal(
                libelle: 'Ajouter au panier',
                icone: Symboles.shoppingBag,
                onPressed: () {},
              ),
              const SizedBox(height: Espaces.m),
              BoutonSecondaire(
                libelle: 'Choisir ma zone manuellement',
                onPressed: () {},
              ),
              const SizedBox(height: Espaces.m),
              BoutonAccentue(libelle: 'Créer un compte', onPressed: () {}),
              const SizedBox(height: Espaces.m),
              BoutonAccentue(
                libelle: 'Se connecter',
                attenue: true,
                onPressed: () {},
              ),
              const SizedBox(height: Espaces.m),
              Row(
                children: [
                  BoutonRond(icone: Symboles.arrowBack, onPressed: () {}),
                  const SizedBox(width: Espaces.m),
                  BoutonRond(
                    icone: Symboles.favorite,
                    remplissage: 1,
                    couleurIcone: Couleurs.orangeVif,
                    onPressed: () {},
                  ),
                  const SizedBox(width: Espaces.m),
                  BoutonRond(icone: Symboles.call, onPressed: () {}),
                  const Spacer(),
                  BoutonPrincipal(
                    libelle: 'Confirmer',
                    pleineLargeur: false,
                    onPressed: () {},
                  ),
                ],
              ),

              _Section('Saisie et filtres'),
              const BarreRecherche(enLectureSeule: true),
              const SizedBox(height: Espaces.l),
              const ChampTexte(
                etiquette: 'Email ou numéro de téléphone',
                indication: 'exemple@mekano.ci',
              ),
              const SizedBox(height: Espaces.l),
              const ChampTexte(etiquette: 'Mot de passe', motDePasse: true),
              const SizedBox(height: Espaces.l),
              Wrap(
                spacing: Espaces.s,
                runSpacing: Espaces.s,
                children: [
                  PuceFiltre(
                    libelle: 'Prix',
                    active: _filtreActif,
                    onTap: () => setState(() => _filtreActif = !_filtreActif),
                  ),
                  PuceFiltre(libelle: 'Catégorie', onTap: () {}),
                  PuceFiltre(libelle: 'Distance', onTap: () {}),
                  PuceFiltre(libelle: 'État', onTap: () {}),
                ],
              ),

              _Section('Signaux de confiance'),
              Wrap(
                spacing: Espaces.m,
                runSpacing: Espaces.m,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: const [
                  BadgeEtat(etat: EtatProduit.neuf),
                  BadgeEtat(etat: EtatProduit.occasion),
                  BadgeEtat(etat: EtatProduit.brade),
                  BadgeVerifie(),
                  EtiquetteDistance(distanceKm: 2.1),
                  EtiquetteDistance(distanceKm: 0.4, commune: 'Cocody'),
                ],
              ),
              const SizedBox(height: Espaces.m),
              const NoteEtoiles(note: 4.5, nbAvis: 128),

              _Section('Cartes'),
              SizedBox(
                height: 268,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CarteProduit(
                        produit: produit,
                        distanceKm: 2,
                        estFavori: _favori,
                        onFavori: () => setState(() => _favori = !_favori),
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: Espaces.m),
                    Expanded(
                      child: CarteProduit(
                        produit: JeuDemonstration.produits[12],
                        distanceKm: 1.2,
                        afficherNote: true,
                        onFavori: () {},
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Espaces.m),
              CarteBoutique(
                boutique: boutique,
                distanceKm: 2,
                suivie: _suivie,
                onSuivre: () => setState(() => _suivie = !_suivie),
                onTap: () {},
              ),

              _Section('Négociation'),
              BulleMessage(
                deMoi: false,
                message: Message(
                  id: '1',
                  idAuteur: 'acheteur',
                  contenu: 'Bonjour ! Le prix est-il négociable ?',
                  horodatage: DateTime.now(),
                ),
              ),
              const SizedBox(height: Espaces.s),
              BulleMessage(
                deMoi: true,
                message: Message(
                  id: '2',
                  idAuteur: 'vendeur',
                  contenu: 'Bonjour, oui un peu selon la quantité.',
                  horodatage: DateTime.now(),
                ),
              ),
              const SizedBox(height: Espaces.s),
              CarteOffre(
                deMoi: false,
                message: Message(
                  id: '3',
                  idAuteur: 'acheteur',
                  contenu: 'Je peux venir le chercher aujourd\'hui.',
                  type: TypeMessage.offre,
                  montantPropose: 40,
                  horodatage: DateTime.now(),
                ),
                onAccepter: () {},
                onRefuser: () {},
                onContrer: () {},
              ),
              const SizedBox(height: Espaces.s),
              CarteOffre(
                deMoi: true,
                message: Message(
                  id: '4',
                  idAuteur: 'vendeur',
                  contenu: '',
                  type: TypeMessage.offre,
                  montantPropose: 42,
                  statutOffre: StatutOffre.acceptee,
                  horodatage: DateTime.now(),
                ),
              ),
              const SizedBox(height: Espaces.l),
              Row(
                children: [
                  Text('Quantité', style: Typographie.echelle.titleMedium),
                  const Spacer(),
                  SelecteurQuantite(
                    quantite: _quantite,
                    onChange: (valeur) => setState(() => _quantite = valeur),
                  ),
                ],
              ),

              _Section('Réglages'),
              SwitchListTile(
                value: _notifications,
                onChanged: (valeur) => setState(() => _notifications = valeur),
                title: Text(
                  'Notifications',
                  style: Typographie.echelle.titleMedium,
                ),
                contentPadding: EdgeInsets.zero,
              ),

              _Section('États'),
              const SizedBox(height: 180, child: EtatChargement()),
              const SizedBox(
                height: 260,
                child: EtatVide(
                  icone: Symboles.searchOff,
                  titre: 'Aucun résultat',
                  message:
                      'Aucune annonce ne correspond à ces filtres dans votre '
                      'zone. Élargissez la distance pour voir plus loin.',
                  libelleAction: 'Élargir la zone',
                ),
              ),
              const SizedBox(height: Espaces.l),
              Row(
                children: [
                  const BlocSquelette(hauteur: 56, largeur: 56),
                  const SizedBox(width: Espaces.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        BlocSquelette(hauteur: 14),
                        SizedBox(height: Espaces.s),
                        BlocSquelette(hauteur: 14, largeur: 140),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Titre séparant deux familles de composants.
class _Section extends StatelessWidget {
  const _Section(this.titre);

  final String titre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Espaces.xxl, bottom: Espaces.l),
      child: Row(
        children: [
          Text(titre.toUpperCase(), style: Typographie.sectionCapitales),
          const SizedBox(width: Espaces.m),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

/// Les quatre blancs de la charte, côte à côte.
///
/// Placés ainsi, les écarts d'un à trois pour cent deviennent lisibles ; pris
/// isolément sur un écran, ils ne se perçoivent que comme de la profondeur.
class _NuancierBlancs extends StatelessWidget {
  const _NuancierBlancs();

  @override
  Widget build(BuildContext context) {
    const nuances = {
      'blanc': Couleurs.blanc,
      'carte': Couleurs.blanc,
      'champ': Couleurs.blancChamp,
      'creux': Couleurs.blancCreux,
    };

    return Row(
      children: nuances.entries.map((nuance) {
        return Expanded(
          child: Container(
            height: 68,
            margin: const EdgeInsets.only(right: Espaces.s),
            decoration: BoxDecoration(
              color: nuance.value,
              borderRadius: Coupes.puce,
              border: Border.all(color: Couleurs.filet),
            ),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(Espaces.s),
            child: Text(nuance.key, style: Typographie.echelle.labelSmall),
          ),
        );
      }).toList(),
    );
  }
}

/// L'accent orange et le noir d'action.
class _NuancierAccents extends StatelessWidget {
  const _NuancierAccents();

  @override
  Widget build(BuildContext context) {
    const nuances = {
      'orange': Couleurs.orange,
      'orange vif': Couleurs.orangeVif,
      'noir': Couleurs.noir,
      'encre': Couleurs.encre,
    };

    return Row(
      children: nuances.entries.map((nuance) {
        return Expanded(
          child: Container(
            height: 68,
            margin: const EdgeInsets.only(right: Espaces.s),
            decoration: BoxDecoration(
              color: nuance.value,
              borderRadius: Coupes.puce,
            ),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(Espaces.s),
            child: Text(
              nuance.key,
              style: Typographie.echelle.labelSmall?.copyWith(
                color: Couleurs.blanc.withValues(alpha: 0.85),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
