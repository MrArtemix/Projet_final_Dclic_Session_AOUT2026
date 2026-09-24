import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/favoris_controller.dart';
import '../controllers/localisation_controller.dart';
import '../controllers/panier_controller.dart';
import '../controllers/produit_controller.dart';
import '../models/utilisateur.dart';
import '../theme/couleurs.dart';
import '../theme/dimensions.dart';
import '../theme/formes.dart';
import '../theme/symboles.dart';
import '../theme/typographie.dart';
import '../widgets/communs/boutons.dart';
import '../widgets/communs/fond_texture.dart';
import '../widgets/metier/indicateurs.dart';
import 'choisir_zone.dart';
import 'onboarding.dart';

/// Compte, préférences et bascule vers le rôle de vendeur.
class Compte extends StatefulWidget {
  const Compte({super.key});

  @override
  State<Compte> createState() => _CompteState();
}

class _CompteState extends State<Compte> {
  bool _notifications = true;
  bool _modeSombre = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final favoris = context.watch<FavorisController>();
    final localisation = context.watch<LocalisationController>();
    final utilisateur = auth.utilisateur;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Mon compte'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Symboles.arrowBack),
        ),
        actions: [
          IconButton(
            onPressed: _ouvrirParametres,
            icon: const Icon(Symboles.settings),
          ),
        ],
      ),
      body: FondTexture(
        child: ListView(
          padding: const EdgeInsets.only(bottom: Espaces.xxl),
          children: [
            _Identite(utilisateur: utilisateur),
            _Chiffres(
              commandes: utilisateur?.nbCommandes ?? 0,
              favoris: favoris.nombre,
              note: utilisateur?.note ?? 0,
            ),

            const _TitreGroupe('GESTION DU COMPTE'),
            _Ligne(
              icone: Symboles.person,
              libelle: 'Informations personnelles',
              onTap: () => _bientot('Modification du profil'),
            ),
            _Ligne(
              icone: Symboles.place,
              libelle: 'Ma zone',
              valeur: localisation.commune?.nom ?? 'Non définie',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ChoisirZone(remplaceLePrecedent: false),
                ),
              ),
            ),
            _Ligne(
              icone: Symboles.creditCard,
              libelle: 'Moyens de paiement',
              valeur: 'Bientôt',
              onTap: () => _bientot(
                'Le paiement par mobile money est prévu en version 3',
              ),
            ),
            _Ligne(
              icone: Symboles.inventory2,
              libelle: 'Mes commandes',
              onTap: () => _bientot('Historique des commandes'),
            ),
            _Ligne(
              icone: Symboles.favorite,
              libelle: 'Mes favoris',
              valeur: '${favoris.nombre}',
              onTap: () => Navigator.of(context).pop(),
            ),

            const _TitreGroupe('VENDRE'),
            _BasculeVendeur(utilisateur: utilisateur),

            const _TitreGroupe('DIVERS'),
            _Ligne(
              icone: Symboles.help,
              libelle: 'Aide et support',
              onTap: () => _bientot('Centre d\'aide'),
            ),
            _Ligne(
              icone: Symboles.description,
              libelle: 'Conditions d\'utilisation',
              onTap: () => _bientot('Conditions d\'utilisation'),
            ),

            const _TitreGroupe('PARAMÈTRES'),
            SwitchListTile(
              value: _notifications,
              onChanged: (valeur) => setState(() => _notifications = valeur),
              secondary: const Icon(Symboles.notifications),
              title: Text(
                'Notifications',
                style: Typographie.echelle.titleMedium,
              ),
              subtitle: Text(
                'Nouveaux messages et offres reçues',
                style: Typographie.echelle.bodySmall,
              ),
              contentPadding: Espaces.ecran,
            ),
            SwitchListTile(
              value: _modeSombre,
              onChanged: (valeur) {
                setState(() => _modeSombre = valeur);
                _bientot('Le thème sombre arrivera dans une prochaine version');
              },
              secondary: const Icon(Symboles.darkMode),
              title: Text(
                'Mode sombre',
                style: Typographie.echelle.titleMedium,
              ),
              contentPadding: Espaces.ecran,
            ),
            _Ligne(
              icone: Symboles.language,
              libelle: 'Langue',
              valeur: 'Français',
              onTap: () => _bientot(
                'D\'autres langues seront ajoutées selon les marchés',
              ),
            ),

            if (context.read<ProduitController>().baseDisponible) ...[
              const _TitreGroupe('DONNÉES'),
              _Ligne(
                icone: Symboles.cloudUpload,
                libelle: 'Charger le jeu de démonstration',
                valeur: 'Firestore',
                onTap: _amorcer,
              ),
            ] else ...[
              const _TitreGroupe('DONNÉES'),
              const _BandeauDemonstration(),
            ],

            const SizedBox(height: Espaces.xl),
            Padding(
              padding: Espaces.ecran,
              child: BoutonSecondaire(
                libelle: 'Se déconnecter',
                icone: Symboles.logout,
                onPressed: _seDeconnecter,
              ),
            ),
            const SizedBox(height: Espaces.l),
            Center(
              child: Text(
                'Mekano Afrika · Version 1.0.0',
                style: Typographie.echelle.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _bientot(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _ouvrirParametres() => _bientot('Réglages avancés');

  Future<void> _amorcer() async {
    final ecrit =
        await context.read<ProduitController>().amorcerDonneesDemonstration();
    if (!mounted) return;

    _bientot(
      ecrit
          ? 'Jeu de démonstration écrit dans Firestore.'
          : 'Les données sont déjà présentes dans Firestore.',
    );

    if (ecrit && mounted) await context.read<ProduitController>().charger();
  }

  Future<void> _seDeconnecter() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (contexteDialogue) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
          'Votre panier et vos favoris seront conservés sur votre compte.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexteDialogue).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(contexteDialogue).pop(true),
            child: Text(
              'Se déconnecter',
              style: Typographie.echelle.labelLarge?.copyWith(
                color: Couleurs.erreur,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirme != true || !mounted) return;

    await context.read<AuthController>().seDeconnecter();
    if (!mounted) return;

    context.read<PanierController>().vider();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const Onboarding()),
      (route) => false,
    );
  }
}

/// Photo, nom et contact.
class _Identite extends StatelessWidget {
  const _Identite({this.utilisateur});

  final Utilisateur? utilisateur;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Espaces.l,
        Espaces.l,
        Espaces.l,
        Espaces.xl,
      ),
      child: Row(
        children: [
          Container(
            height: 78,
            width: 78,
            decoration: BoxDecoration(
              color: Couleurs.blancChamp,
              shape: BoxShape.circle,
              border: Border.all(color: Couleurs.filet, width: 2),
            ),
            child: const Icon(
              Symboles.person,
              fill: 1,
              size: 36,
              color: Couleurs.encreDouce,
            ),
          ),
          const SizedBox(width: Espaces.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        utilisateur?.nom ?? 'Visiteur',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Typographie.echelle.headlineMedium,
                      ),
                    ),
                    if (utilisateur?.verifie ?? false) ...[
                      const SizedBox(width: Espaces.xs),
                      const BadgeVerifie(taille: 17),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  utilisateur?.contact ?? 'Non connecté',
                  style: Typographie.echelle.bodyMedium,
                ),
                if (utilisateur != null) ...[
                  const SizedBox(height: Espaces.s),
                  _EtiquetteStatut(utilisateur: utilisateur!),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Symboles.edit, size: 20),
          ),
        ],
      ),
    );
  }
}

/// Type de compte et statut de vendeur.
class _EtiquetteStatut extends StatelessWidget {
  const _EtiquetteStatut({required this.utilisateur});

  final Utilisateur utilisateur;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Espaces.s,
      children: [
        _Pastille(libelle: utilisateur.typeCompte.libelle),
        if (utilisateur.statutVendeur != StatutVendeur.aucun)
          _Pastille(
            libelle: utilisateur.statutVendeur.libelle,
            accentuee: true,
          ),
      ],
    );
  }
}

class _Pastille extends StatelessWidget {
  const _Pastille({required this.libelle, this.accentuee = false});

  final String libelle;
  final bool accentuee;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Espaces.s,
        vertical: Espaces.xs,
      ),
      decoration: BoxDecoration(
        color: accentuee ? Couleurs.orangePale : Couleurs.blancChamp,
        borderRadius: Coupes.badge,
        border: Border.all(
          color: accentuee ? Couleurs.orange.withValues(alpha: 0.3) : Couleurs.filet,
        ),
      ),
      child: Text(
        libelle,
        style: Typographie.echelle.labelSmall?.copyWith(
          color: accentuee ? Couleurs.orangeVif : Couleurs.encreDouce,
          fontSize: 11,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

/// Commandes, favoris, note.
class _Chiffres extends StatelessWidget {
  const _Chiffres({
    required this.commandes,
    required this.favoris,
    required this.note,
  });

  final int commandes;
  final int favoris;
  final double note;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Espaces.l, 0, Espaces.l, Espaces.l),
      child: Row(
        children: [
          _Chiffre(valeur: '$commandes', libelle: 'Commandes'),
          _Chiffre(valeur: '$favoris', libelle: 'Favoris'),
          _Chiffre(
            valeur: note > 0 ? note.toStringAsFixed(1) : '—',
            libelle: 'Note',
          ),
        ],
      ),
    );
  }
}

class _Chiffre extends StatelessWidget {
  const _Chiffre({required this.valeur, required this.libelle});

  final String valeur;
  final String libelle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(valeur, style: Typographie.echelle.headlineMedium),
          Text(libelle, style: Typographie.echelle.bodySmall),
        ],
      ),
    );
  }
}

/// Passage du rôle d'acheteur à celui de vendeur.
///
/// Règle du dossier de conception : ce changement se fait **sans créer de
/// second compte**, et un statut informel n'entraîne aucune restriction.
class _BasculeVendeur extends StatelessWidget {
  const _BasculeVendeur({this.utilisateur});

  final Utilisateur? utilisateur;

  @override
  Widget build(BuildContext context) {
    final dejaVendeur = utilisateur != null &&
        utilisateur!.statutVendeur != StatutVendeur.aucun;

    return Padding(
      padding: Espaces.ecran,
      child: Container(
        padding: const EdgeInsets.all(Espaces.l),
        decoration: BoxDecoration(
          color: Couleurs.blanc,
          borderRadius: Coupes.carte,
          border: Border.all(color: Couleurs.filet),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Symboles.storefront,
                  size: 22,
                  color: Couleurs.encre,
                ),
                const SizedBox(width: Espaces.m),
                Expanded(
                  child: Text(
                    dejaVendeur ? 'Vous vendez déjà' : 'Devenir vendeur',
                    style: Typographie.echelle.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Espaces.s),
            Text(
              dejaVendeur
                  ? 'Déposez une annonce en quelques instants. Aucun document '
                      'n\'est exigé.'
                  : 'Vendez votre matériel sans créer un second compte. '
                      'Aucun registre de commerce n\'est demandé : les '
                      'vendeurs informels accèdent aux mêmes fonctions.',
              style: Typographie.echelle.bodySmall,
            ),
            const SizedBox(height: Espaces.l),
            Row(
              children: [
                if (!dejaVendeur)
                  Expanded(
                    child: BoutonSecondaire(
                      libelle: 'Activer la vente',
                      onPressed: () => _activer(context),
                    ),
                  )
                else
                  Expanded(
                    child: BoutonPrincipal(
                      libelle: 'Déposer une annonce',
                      icone: Symboles.add,
                      onPressed: () => ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                        content: Text(
                          'Le dépôt d\'annonce arrive avec le module vendeur.',
                        ),
                      )),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _activer(BuildContext context) async {
    final statut = await showModalBottomSheet<StatutVendeur>(
      context: context,
      builder: (contexteFeuille) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(Espaces.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quel type de vendeur êtes-vous ?',
                    style: Typographie.echelle.titleLarge,
                  ),
                  const SizedBox(height: Espaces.xs),
                  Text(
                    'Ce choix est déclaratif. Il n\'ouvre ni ne ferme aucun '
                    'accès, et reste modifiable à tout moment.',
                    style: Typographie.echelle.bodySmall,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Symboles.storefront),
              title: const Text('Vendeur formel'),
              subtitle: const Text('Boutique ou entreprise enregistrée'),
              onTap: () =>
                  Navigator.of(contexteFeuille).pop(StatutVendeur.formel),
            ),
            ListTile(
              leading: const Icon(Symboles.handyman),
              title: const Text('Vendeur informel'),
              subtitle: const Text(
                'Particulier, réparateur ou revendeur sans structure',
              ),
              onTap: () =>
                  Navigator.of(contexteFeuille).pop(StatutVendeur.informel),
            ),
            const SizedBox(height: Espaces.m),
          ],
        ),
      ),
    );

    if (statut == null || !context.mounted) return;

    await context.read<AuthController>().mettreAJourProfil(
          statutVendeur: statut,
        );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Statut enregistré : ${statut.libelle}.')),
    );
  }
}

/// Rappel du fonctionnement hors Firebase.
class _BandeauDemonstration extends StatelessWidget {
  const _BandeauDemonstration();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Espaces.ecran,
      child: Container(
        padding: const EdgeInsets.all(Espaces.l),
        decoration: BoxDecoration(
          color: Couleurs.blancChamp,
          borderRadius: Coupes.puce,
          border: Border.all(color: Couleurs.filet),
        ),
        child: Row(
          children: [
            const Icon(
              Symboles.cloudOff,
              size: 20,
              color: Couleurs.encreDouce,
            ),
            const SizedBox(width: Espaces.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mode démonstration',
                    style: Typographie.echelle.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Firebase n\'est pas configuré : l\'application fonctionne '
                    'sur son jeu de données local.',
                    style: Typographie.echelle.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Intertitre d'un groupe de réglages.
class _TitreGroupe extends StatelessWidget {
  const _TitreGroupe(this.titre);

  final String titre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Espaces.l,
        Espaces.xl,
        Espaces.l,
        Espaces.s,
      ),
      child: Text(titre, style: Typographie.sectionCapitales),
    );
  }
}

/// Une entrée de réglage.
class _Ligne extends StatelessWidget {
  const _Ligne({
    required this.icone,
    required this.libelle,
    required this.onTap,
    this.valeur,
  });

  final IconData icone;
  final String libelle;
  final String? valeur;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: Espaces.ecran,
      leading: Icon(icone, size: 21, color: Couleurs.encreDouce),
      title: Text(libelle, style: Typographie.echelle.titleMedium),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (valeur != null)
            Text(valeur!, style: Typographie.echelle.bodySmall),
          const SizedBox(width: Espaces.xs),
          const Icon(
            Symboles.chevronRight,
            size: 20,
            color: Couleurs.encrePale,
          ),
        ],
      ),
    );
  }
}
