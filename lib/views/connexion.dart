import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
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
import 'inscription.dart';

/// Connexion à un compte existant.
class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  final _formulaire = GlobalKey<FormState>();
  final _contact = TextEditingController();
  final _motDePasse = TextEditingController();
  bool _resterConnecte = true;

  @override
  void dispose() {
    _contact.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    if (!_formulaire.currentState!.validate()) return;

    final reussi = await context.read<AuthController>().seConnecter(
          contact: _contact.text,
          motDePasse: _motDePasse.text,
        );

    if (!mounted || !reussi) return;
    _entrer();
  }

  /// Ouvre une session de démonstration, sans identifiants.
  ///
  /// Indispensable pour présenter l'application lorsque Firebase n'est pas
  /// configuré, et pratique pour parcourir le produit sans créer de compte.
  void _entrerEnDemonstration() {
    context.read<AuthController>().ouvrirSessionDemonstration();
    _entrer();
  }

  void _entrer() => Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const AutoriserLocalisation()),
      );

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FondTexture(
        ambiance: AmbianceFond.chaude,
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
                      Espaces.xxl,
                      Espaces.l,
                      Espaces.xxl,
                    ),
                    children: [
                      Text(
                        'Connexion',
                        textAlign: TextAlign.center,
                        style: Typographie.echelle.headlineLarge,
                      ),
                      const SizedBox(height: Espaces.s),
                      Text(
                        'Retrouvez vos favoris, vos commandes et vos '
                        'négociations en cours.',
                        textAlign: TextAlign.center,
                        style: Typographie.echelle.bodyMedium,
                      ),
                      const SizedBox(height: Espaces.xxl),

                      ChampTexte(
                        etiquette: 'Email ou numéro de téléphone',
                        controleur: _contact,
                        indication: 'exemple@mekano.ci',
                        typeClavier: TextInputType.emailAddress,
                        actionClavier: TextInputAction.next,
                        validateur: (valeur) =>
                            (valeur == null || valeur.trim().isEmpty)
                                ? 'Indiquez votre email ou votre numéro.'
                                : null,
                      ),
                      const SizedBox(height: Espaces.l),

                      ChampTexte(
                        etiquette: 'Mot de passe',
                        controleur: _motDePasse,
                        motDePasse: true,
                        actionClavier: TextInputAction.done,
                        validateur: (valeur) =>
                            (valeur == null || valeur.isEmpty)
                                ? 'Saisissez votre mot de passe.'
                                : null,
                      ),
                      const SizedBox(height: Espaces.s),

                      // Les deux libellés ne tiennent pas côte à côte sur un
                      // écran étroit : la case et son texte cèdent la place en
                      // premier, le lien d'oubli gardant sa formulation
                      // entière.
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _resterConnecte,
                                  onChanged: (valeur) => setState(
                                    () => _resterConnecte = valeur ?? true,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                const SizedBox(width: Espaces.xs),
                                Flexible(
                                  child: Text(
                                    'Rester connecté',
                                    overflow: TextOverflow.ellipsis,
                                    style: Typographie.echelle.bodyMedium
                                        ?.copyWith(color: Couleurs.encre),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _motDePasseOublie,
                            child: const Text('Mot de passe oublié ?'),
                          ),
                        ],
                      ),

                      if (auth.erreur.isNotEmpty) ...[
                        const SizedBox(height: Espaces.m),
                        _Alerte(message: auth.erreur),
                      ],

                      const SizedBox(height: Espaces.l),
                      BoutonAccentue(
                        libelle: 'Se connecter',
                        enChargement: auth.enCours,
                        onPressed: _valider,
                      ),

                      const SizedBox(height: Espaces.xl),
                      const _Separateur(libelle: 'ou'),
                      const SizedBox(height: Espaces.xl),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ConnexionExterne(
                            libelle: 'Google',
                            icone: Icons.g_mobiledata_rounded,
                            couleur: const Color(0xFFDB4437),
                            onTap: _connexionExterneIndisponible,
                          ),
                          const SizedBox(width: Espaces.l),
                          _ConnexionExterne(
                            libelle: 'Facebook',
                            icone: Icons.facebook,
                            couleur: const Color(0xFF1877F2),
                            onTap: _connexionExterneIndisponible,
                          ),
                        ],
                      ),

                      const SizedBox(height: Espaces.xl),
                      Center(
                        child: TextButton.icon(
                          onPressed: _entrerEnDemonstration,
                          icon: const Icon(Symboles.visibility, size: 18),
                          label: const Text('Découvrir sans compte'),
                        ),
                      ),

                      const SizedBox(height: Espaces.m),
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Vous n\'avez pas de compte ? ',
                              style: Typographie.echelle.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute<void>(
                                builder: (_) => const Inscription(),
                              )),
                              child: const Text('S\'inscrire'),
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

  void _motDePasseOublie() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Un lien de réinitialisation sera envoyé sur votre contact.',
        ),
      ),
    );
  }

  /// La connexion par Google et Facebook est prévue au cahier des charges mais
  /// dépend d'une configuration propre à chaque plateforme, hors périmètre de
  /// la version initiale. Le parcours est donc signalé plutôt que simulé.
  void _connexionExterneIndisponible() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Connexion externe prévue après configuration du fournisseur.',
        ),
      ),
    );
  }
}

/// Trait horizontal portant un mot au centre.
class _Separateur extends StatelessWidget {
  const _Separateur({required this.libelle});

  final String libelle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Espaces.m),
          child: Text(
            libelle,
            style: Typographie.echelle.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

/// Bouton de connexion par un fournisseur externe.
class _ConnexionExterne extends StatelessWidget {
  const _ConnexionExterne({
    required this.libelle,
    required this.icone,
    required this.couleur,
    required this.onTap,
  });

  final String libelle;
  final IconData icone;
  final Color couleur;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Couleurs.blanc,
      shape: const CircleBorder(side: BorderSide(color: Couleurs.filetMarque)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Tooltip(
          message: 'Continuer avec $libelle',
          child: SizedBox(
            height: 56,
            width: 56,
            child: Icon(icone, size: 30, color: couleur),
          ),
        ),
      ),
    );
  }
}

/// Bandeau d'erreur affiché sous le formulaire.
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
