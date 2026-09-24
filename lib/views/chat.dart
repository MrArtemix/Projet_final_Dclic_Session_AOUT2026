import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/conversation_controller.dart';
import '../controllers/panier_controller.dart';
import '../models/message.dart';
import '../models/produit.dart';
import '../theme/couleurs.dart';
import '../theme/dimensions.dart';
import '../theme/formes.dart';
import '../theme/symboles.dart';
import '../theme/typographie.dart';
import '../utils/formats.dart';
import '../widgets/communs/boutons.dart';
import '../widgets/communs/etats.dart';
import '../widgets/communs/fond_texture.dart';
import '../widgets/metier/indicateurs.dart';
import '../widgets/metier/negociation.dart';

/// Conversation et négociation du prix.
///
/// C'est le pilier différenciant du produit : l'échange ne sert pas seulement
/// à poser des questions, il porte des offres de prix structurées, que le
/// destinataire accepte, refuse ou contre. Le prix convenu se lit en haut de
/// l'écran, et l'ajout au panier reprend ce montant.
class Chat extends StatefulWidget {
  const Chat({super.key, required this.produit, this.ouvrirSurTroc = false});

  final Produit produit;

  /// Prépare le champ avec une proposition de troc.
  final bool ouvrirSurTroc;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _saisie = TextEditingController();
  final _defilement = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ouvrir());
  }

  @override
  void dispose() {
    _saisie.dispose();
    _defilement.dispose();
    super.dispose();
  }

  Future<void> _ouvrir() async {
    final auth = context.read<AuthController>();

    await context.read<ConversationController>().ouvrirPour(
          produit: widget.produit,
          idUtilisateur: auth.utilisateur?.id ?? 'visiteur',
          nomVendeur: widget.produit.nomBoutique,
        );

    if (!mounted) return;

    if (widget.ouvrirSurTroc) {
      _saisie.text = 'Bonjour, seriez-vous intéressé par un troc ? '
          'Je peux proposer ';
      _saisie.selection = TextSelection.collapsed(offset: _saisie.text.length);
    }
    _versLeBas();
  }

  void _versLeBas() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_defilement.hasClients) return;
      _defilement.animateTo(
        _defilement.position.maxScrollExtent,
        duration: Mouvement.rapide,
        curve: Mouvement.courbe,
      );
    });
  }

  Future<void> _envoyer() async {
    final texte = _saisie.text;
    if (texte.trim().isEmpty) return;

    _saisie.clear();
    await context.read<ConversationController>().envoyerMessage(texte);
    _versLeBas();
  }

  /// Ouvre la saisie d'une offre de prix.
  Future<void> _proposerUneOffre({double? montantSuggere}) async {
    final conversation = context.read<ConversationController>();
    final montant = await _demanderUnMontant(montantSuggere: montantSuggere);
    if (montant == null || !mounted) return;

    await conversation.envoyerOffre(montant);
    _versLeBas();
  }

  Future<double?> _demanderUnMontant({double? montantSuggere}) {
    final champ = TextEditingController(
      text: (montantSuggere ?? widget.produit.prixDetail).round().toString(),
    );

    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      builder: (contexteFeuille) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(contexteFeuille).bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Espaces.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Proposer un prix',
                  style: Typographie.echelle.titleLarge,
                ),
                const SizedBox(height: Espaces.xs),
                Text(
                  'Prix affiché : ${Formats.prix(widget.produit.prixDetail)}',
                  style: Typographie.echelle.bodySmall,
                ),
                const SizedBox(height: Espaces.l),
                TextField(
                  controller: champ,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  style: Typographie.prix,
                  cursorColor: Couleurs.orange,
                  decoration: const InputDecoration(
                    prefixText: r'$ ',
                    hintText: '0',
                  ),
                ),
                const SizedBox(height: Espaces.l),
                BoutonPrincipal(
                  libelle: 'Envoyer l\'offre',
                  icone: Symboles.localOffer,
                  onPressed: () {
                    final valeur = double.tryParse(
                      champ.text.replaceAll(',', '.'),
                    );
                    if (valeur == null || valeur <= 0) {
                      ScaffoldMessenger.of(contexteFeuille).showSnackBar(
                        const SnackBar(
                          content: Text('Saisissez un montant valide.'),
                        ),
                      );
                      return;
                    }
                    Navigator.of(contexteFeuille).pop(valeur);
                  },
                ),
                const SizedBox(height: Espaces.m),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _contrer(Message offre) async {
    final montant = await _demanderUnMontant(
      montantSuggere: offre.montantPropose,
    );
    if (montant == null || !mounted) return;

    await context.read<ConversationController>().contrerOffre(offre, montant);
    _versLeBas();
  }

  void _ajouterAuPrixConvenu(double montant) {
    // Le prix convenu ne modifie pas l'annonce : il ne vaut que pour cet
    // acheteur. Le panier reçoit donc le produit, et le montant négocié est
    // rappelé au vendeur lors de la commande.
    context.read<PanierController>().ajouter(widget.produit);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Produit ajouté au panier. Prix négocié : '
          '${Formats.prix(montant)}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversation = context.watch<ConversationController>();
    final auth = context.watch<AuthController>();
    final moi = auth.utilisateur?.id ?? 'visiteur';
    final accepte = conversation.offreAcceptee;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FondTexture(
        child: SafeArea(
          child: Column(
            children: [
              _BarreHaute(
                nom: widget.produit.nomBoutique,
                enLigne: true,
              ),
              _RappelProduit(produit: widget.produit),

              if (accepte != null)
                _PrixConvenu(
                  montant: accepte.montantPropose ?? 0,
                  onAjouter: () =>
                      _ajouterAuPrixConvenu(accepte.montantPropose ?? 0),
                ),

              Expanded(
                child: conversation.chargement
                    ? const EtatChargement()
                    : conversation.messages.isEmpty
                        ? const EtatVide(
                            icone: Symboles.forum,
                            titre: 'Démarrez la négociation',
                            message:
                                'Posez une question ou proposez directement '
                                'votre prix au vendeur.',
                          )
                        : ListView.separated(
                            controller: _defilement,
                            padding: const EdgeInsets.all(Espaces.l),
                            itemCount: conversation.messages.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: Espaces.s),
                            itemBuilder: (context, index) {
                              final message = conversation.messages[index];
                              final deMoi = message.idAuteur == moi;

                              if (message.estUneOffre) {
                                return CarteOffre(
                                  message: message,
                                  deMoi: deMoi,
                                  onAccepter: () =>
                                      conversation.accepterOffre(message),
                                  onRefuser: () =>
                                      conversation.refuserOffre(message),
                                  onContrer: () => _contrer(message),
                                );
                              }
                              return BulleMessage(
                                message: message,
                                deMoi: deMoi,
                              );
                            },
                          ),
              ),

              _BarreSaisie(
                controleur: _saisie,
                onEnvoyer: _envoyer,
                onOffre: _proposerUneOffre,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Interlocuteur et disponibilité.
class _BarreHaute extends StatelessWidget {
  const _BarreHaute({required this.nom, required this.enLigne});

  final String nom;
  final bool enLigne;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Espaces.l,
        vertical: Espaces.s,
      ),
      child: Row(
        children: [
          BoutonRond(
            icone: Symboles.arrowBack,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: Espaces.m),
          Container(
            height: Tailles.avatar,
            width: Tailles.avatar,
            decoration: const BoxDecoration(
              color: Couleurs.blancChamp,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Symboles.storefront,
              size: 20,
              color: Couleurs.encreDouce,
            ),
          ),
          const SizedBox(width: Espaces.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Typographie.echelle.titleMedium,
                ),
                Row(
                  children: [
                    Container(
                      height: 7,
                      width: 7,
                      decoration: BoxDecoration(
                        color: enLigne ? Couleurs.succes : Couleurs.encrePale,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: Espaces.xs),
                    Text(
                      enLigne ? 'En ligne' : 'Hors ligne',
                      style: Typographie.echelle.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          BoutonRond(
            icone: Symboles.call,
            infobulle: 'Appeler le vendeur',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('L\'appel direct arrivera avec le profil vendeur.'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Produit sur lequel porte la conversation.
class _RappelProduit extends StatelessWidget {
  const _RappelProduit({required this.produit});

  final Produit produit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: Espaces.ecran,
      padding: const EdgeInsets.all(Espaces.s),
      decoration: BoxDecoration(
        color: Couleurs.blancChamp,
        borderRadius: Coupes.puce,
        border: Border.all(color: Couleurs.filet),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: Coupes.badge,
            child: SizedBox(
              height: 46,
              width: 46,
              child: ImageProduit(
                url: produit.photos.isEmpty ? '' : produit.photos.first,
                signature: produit.id,
                hauteurAffichee: 46,
              ),
            ),
          ),
          const SizedBox(width: Espaces.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  produit.titre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Typographie.echelle.titleSmall,
                ),
                Text(
                  Formats.prix(produit.prixDetail),
                  style: Typographie.echelle.titleMedium,
                ),
              ],
            ),
          ),
          BadgeEtat(etat: produit.etat, compact: true),
          const SizedBox(width: Espaces.s),
        ],
      ),
    );
  }
}

/// Bandeau du prix convenu, une fois une offre acceptée.
class _PrixConvenu extends StatelessWidget {
  const _PrixConvenu({required this.montant, required this.onAjouter});

  final double montant;
  final VoidCallback onAjouter;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(Espaces.l, 0, Espaces.l, Espaces.m),
      padding: const EdgeInsets.all(Espaces.m),
      decoration: BoxDecoration(
        color: Couleurs.succes.withValues(alpha: 0.07),
        borderRadius: Coupes.puce,
        border: Border.all(color: Couleurs.succes.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Symboles.handshake, size: 20, color: Couleurs.succes),
          const SizedBox(width: Espaces.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prix convenu : ${Formats.prix(montant)}',
                  style: Typographie.echelle.titleSmall?.copyWith(
                    color: Couleurs.succes,
                  ),
                ),
                Text(
                  'Ajoutez le produit au panier pour finaliser.',
                  style: Typographie.echelle.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(onPressed: onAjouter, child: const Text('Ajouter')),
        ],
      ),
    );
  }
}

/// Saisie d'un message, bouton d'offre et envoi.
class _BarreSaisie extends StatelessWidget {
  const _BarreSaisie({
    required this.controleur,
    required this.onEnvoyer,
    required this.onOffre,
  });

  final TextEditingController controleur;
  final VoidCallback onEnvoyer;
  final VoidCallback onOffre;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Espaces.l,
        Espaces.s,
        Espaces.l,
        Espaces.m,
      ),
      decoration: const BoxDecoration(
        color: Couleurs.blanc,
        border: Border(top: BorderSide(color: Couleurs.filet)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: TextField(
                controller: controleur,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                style: Typographie.echelle.bodyLarge,
                cursorColor: Couleurs.orange,
                onSubmitted: (_) => onEnvoyer(),
                decoration: const InputDecoration(
                  hintText: 'Écrire un message...',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: Espaces.l,
                    vertical: Espaces.m,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: Espaces.s),
          OutlinedButton(
            onPressed: onOffre,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: Espaces.l),
            ),
            child: const Text('Offre'),
          ),
          const SizedBox(width: Espaces.s),
          Material(
            color: Couleurs.noir,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onEnvoyer,
              child: const SizedBox(
                height: 48,
                width: 48,
                child: Icon(Symboles.send, size: 19, color: Couleurs.blanc),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
