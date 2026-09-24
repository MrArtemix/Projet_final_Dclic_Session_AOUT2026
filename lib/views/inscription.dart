import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/localisation_controller.dart';
import '../donnees/communes.dart';
import '../models/utilisateur.dart';
import '../theme/couleurs.dart';
import '../theme/dimensions.dart';
import '../theme/formes.dart';
import '../theme/symboles.dart';
import '../theme/typographie.dart';
import '../widgets/communs/boutons.dart';
import '../widgets/communs/champs.dart';
import '../widgets/communs/fond_texture.dart';
import '../widgets/communs/logo.dart';
import 'autoriser_localisation.dart';
import 'connexion.dart';

/// Création d'un compte.
///
/// Le formulaire est délibérément court. Le cahier des charges insiste sur ce
/// point : un réparateur de quartier peu à l'aise avec le numérique doit
/// pouvoir s'inscrire en quelques instants. Le statut de vendeur est déclaré
/// ici, sans pièce justificative, et **n'ouvre ni ne ferme aucun accès**.
class Inscription extends StatefulWidget {
  const Inscription({super.key});

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  final _formulaire = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _contact = TextEditingController();
  final _motDePasse = TextEditingController();
  final _confirmation = TextEditingController();

  TypeCompte _typeCompte = TypeCompte.particulier;
  StatutVendeur _statutVendeur = StatutVendeur.aucun;
  Commune _commune = Communes.parDefaut;
  bool _conditionsAcceptees = false;

  @override
  void dispose() {
    _nom.dispose();
    _contact.dispose();
    _motDePasse.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    if (!_formulaire.currentState!.validate()) return;

    if (!_conditionsAcceptees) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions d\'utilisation.'),
        ),
      );
      return;
    }

    final auth = context.read<AuthController>();
    final reussi = await auth.creerCompte(
      nom: _nom.text,
      contact: _contact.text,
      motDePasse: _motDePasse.text,
      typeCompte: _typeCompte,
      statutVendeur: _statutVendeur,
      commune: _commune.nom,
    );

    if (!mounted) return;

    if (reussi) {
      context.read<LocalisationController>().choisirCommune(_commune);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const AutoriserLocalisation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FondTexture(
        child: SafeArea(
          child: Column(
            children: [
              EnteteMarque(onRetour: () => Navigator.of(context).pop()),
              Expanded(
                child: Form(
                  key: _formulaire,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      Espaces.l,
                      Espaces.l,
                      Espaces.l,
                      Espaces.xxl,
                    ),
                    children: [
                      Text(
                        'Créer votre compte',
                        textAlign: TextAlign.center,
                        style: Typographie.echelle.headlineLarge,
                      ),
                      const SizedBox(height: Espaces.xl),
                      const Center(child: _ChoixPhoto()),
                      const SizedBox(height: Espaces.xl),

                      ChampTexte(
                        etiquette: 'Nom complet',
                        controleur: _nom,
                        indication: 'Jean Kouassi',
                        actionClavier: TextInputAction.next,
                        validateur: (valeur) =>
                            (valeur == null || valeur.trim().length < 2)
                                ? 'Indiquez votre nom.'
                                : null,
                      ),
                      const SizedBox(height: Espaces.l),

                      ChampTexte(
                        etiquette: 'Email ou numéro de téléphone',
                        controleur: _contact,
                        indication: 'exemple@mekano.ci',
                        typeClavier: TextInputType.emailAddress,
                        actionClavier: TextInputAction.next,
                        validateur: _validerContact,
                      ),
                      const SizedBox(height: Espaces.l),

                      _ChoixCommune(
                        commune: _commune,
                        onChange: (valeur) => setState(() => _commune = valeur),
                      ),
                      const SizedBox(height: Espaces.l),

                      ChampTexte(
                        etiquette: 'Mot de passe',
                        controleur: _motDePasse,
                        motDePasse: true,
                        actionClavier: TextInputAction.next,
                        validateur: (valeur) =>
                            (valeur == null || valeur.length < 6)
                                ? 'Six caractères au minimum.'
                                : null,
                      ),
                      const SizedBox(height: Espaces.l),

                      ChampTexte(
                        etiquette: 'Confirmer le mot de passe',
                        controleur: _confirmation,
                        motDePasse: true,
                        actionClavier: TextInputAction.done,
                        validateur: (valeur) => valeur != _motDePasse.text
                            ? 'Les deux mots de passe diffèrent.'
                            : null,
                      ),
                      const SizedBox(height: Espaces.xl),

                      _ChoixTypeCompte(
                        valeur: _typeCompte,
                        onChange: (valeur) =>
                            setState(() => _typeCompte = valeur),
                      ),
                      const SizedBox(height: Espaces.xl),

                      _ChoixStatutVendeur(
                        valeur: _statutVendeur,
                        onChange: (valeur) =>
                            setState(() => _statutVendeur = valeur),
                      ),
                      const SizedBox(height: Espaces.l),

                      CheckboxListTile(
                        value: _conditionsAcceptees,
                        onChanged: (valeur) => setState(
                          () => _conditionsAcceptees = valeur ?? false,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'J\'accepte les conditions d\'utilisation',
                          style: Typographie.echelle.bodyMedium?.copyWith(
                            color: Couleurs.encre,
                          ),
                        ),
                      ),

                      if (auth.erreur.isNotEmpty) ...[
                        const SizedBox(height: Espaces.s),
                        _Alerte(message: auth.erreur),
                      ],

                      const SizedBox(height: Espaces.l),
                      BoutonAccentue(
                        libelle: 'Créer un compte',
                        enChargement: auth.enCours,
                        onPressed: _valider,
                      ),
                      const SizedBox(height: Espaces.l),
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Déjà inscrit ? ',
                              style: Typographie.echelle.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute<void>(
                                builder: (_) => const Connexion(),
                              )),
                              child: const Text('Se connecter'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Accepte indifféremment une adresse électronique ou un numéro, les deux
  /// modes d'inscription prévus au cahier des charges.
  String? _validerContact(String? valeur) {
    final saisie = (valeur ?? '').trim();
    if (saisie.isEmpty) return 'Indiquez un email ou un numéro.';

    final estEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(saisie);
    final estTelephone =
        RegExp(r'^\+?[0-9\s]{8,}$').hasMatch(saisie);

    if (!estEmail && !estTelephone) {
      return 'Saisissez un email valide ou un numéro de téléphone.';
    }
    return null;
  }
}

/// Emplacement de la photo de profil.
class _ChoixPhoto extends StatelessWidget {
  const _ChoixPhoto();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 84,
          width: 84,
          decoration: BoxDecoration(
            color: Couleurs.blancChamp,
            shape: BoxShape.circle,
            border: Border.all(color: Couleurs.filet),
          ),
          child: const Icon(Symboles.add, size: 30, color: Couleurs.encreDouce),
        ),
        const SizedBox(height: Espaces.s),
        Text('Photo de profil', style: Typographie.echelle.labelMedium),
      ],
    );
  }
}

/// Commune de résidence, choisie dans une liste.
class _ChoixCommune extends StatelessWidget {
  const _ChoixCommune({required this.commune, required this.onChange});

  final Commune commune;
  final ValueChanged<Commune> onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: Espaces.xs, bottom: Espaces.s),
          child: Text(
            'Commune de résidence',
            style: Typographie.echelle.labelMedium,
          ),
        ),
        DropdownButtonFormField<Commune>(
          initialValue: commune,
          isExpanded: true,
          icon: const Icon(Symboles.keyboardArrowDown),
          style: Typographie.echelle.bodyLarge,
          items: Communes.toutes
              .map((valeur) => DropdownMenuItem(
                    value: valeur,
                    child: Text(valeur.libelleComplet),
                  ))
              .toList(),
          onChanged: (valeur) {
            if (valeur != null) onChange(valeur);
          },
        ),
      ],
    );
  }
}

/// Particulier ou entreprise.
class _ChoixTypeCompte extends StatelessWidget {
  const _ChoixTypeCompte({required this.valeur, required this.onChange});

  final TypeCompte valeur;
  final ValueChanged<TypeCompte> onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TYPE DE COMPTE', style: Typographie.sectionCapitales),
        const SizedBox(height: Espaces.m),
        Row(
          children: TypeCompte.values.map((type) {
            final actif = type == valeur;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: Espaces.s),
                child: _Option(
                  libelle: type.libelle,
                  icone: type == TypeCompte.particulier
                      ? Symboles.person
                      : Symboles.business,
                  actif: actif,
                  onTap: () => onChange(type),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Statut déclaré du vendeur.
///
/// Le texte d'accompagnement est important : il indique explicitement qu'aucun
/// document n'est exigé et qu'un statut informel n'entraîne aucune
/// restriction. C'est la promesse du produit, elle doit être lisible ici.
class _ChoixStatutVendeur extends StatelessWidget {
  const _ChoixStatutVendeur({required this.valeur, required this.onChange});

  final StatutVendeur valeur;
  final ValueChanged<StatutVendeur> onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('VOUS SOUHAITEZ VENDRE ?', style: Typographie.sectionCapitales),
        const SizedBox(height: Espaces.m),
        Row(
          children: StatutVendeur.values.map((statut) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: Espaces.s),
                child: _Option(
                  libelle: statut == StatutVendeur.aucun
                      ? 'Acheter'
                      : statut == StatutVendeur.formel
                          ? 'Formel'
                          : 'Informel',
                  icone: statut == StatutVendeur.aucun
                      ? Symboles.shoppingBag
                      : statut == StatutVendeur.formel
                          ? Symboles.storefront
                          : Symboles.handyman,
                  actif: statut == valeur,
                  onTap: () => onChange(statut),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: Espaces.m),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Symboles.info,
              size: 15,
              color: Couleurs.encrePale,
            ),
            const SizedBox(width: Espaces.s),
            Expanded(
              child: Text(
                'Aucun document n\'est demandé. Un vendeur informel accède '
                'aux mêmes fonctions qu\'une boutique enregistrée.',
                style: Typographie.echelle.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Bouton d'un choix exclusif.
class _Option extends StatelessWidget {
  const _Option({
    required this.libelle,
    required this.icone,
    required this.actif,
    required this.onTap,
  });

  final String libelle;
  final IconData icone;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: actif ? Couleurs.orangePale : Couleurs.blanc,
      borderRadius: Coupes.puce,
      child: InkWell(
        onTap: onTap,
        borderRadius: Coupes.puce,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: Espaces.m),
          decoration: BoxDecoration(
            borderRadius: Coupes.puce,
            border: Border.all(
              color: actif ? Couleurs.orange : Couleurs.filetMarque,
              width: actif ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icone,
                size: 20,
                color: actif ? Couleurs.orangeVif : Couleurs.encreDouce,
              ),
              const SizedBox(height: Espaces.xs),
              Text(
                libelle,
                textAlign: TextAlign.center,
                style: Typographie.echelle.labelMedium?.copyWith(
                  color: actif ? Couleurs.orangeVif : Couleurs.encre,
                  fontWeight: actif ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bandeau d'erreur affiché sous un formulaire.
class _Alerte extends StatelessWidget {
  const _Alerte({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Espaces.m),
      decoration: BoxDecoration(
        color: Couleurs.erreur.withValues(alpha: 0.07),
        borderRadius: Coupes.puce,
        border: Border.all(color: Couleurs.erreur.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Symboles.error, size: 18, color: Couleurs.erreur),
          const SizedBox(width: Espaces.s),
          Expanded(
            child: Text(
              message,
              style: Typographie.echelle.bodySmall?.copyWith(
                color: Couleurs.erreur,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
