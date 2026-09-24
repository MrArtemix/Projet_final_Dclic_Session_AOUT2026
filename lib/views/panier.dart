import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/panier_controller.dart';
import '../models/article_panier.dart';
import '../theme/couleurs.dart';
import '../theme/dimensions.dart';
import '../theme/formes.dart';
import '../theme/symboles.dart';
import '../theme/profondeur.dart';
import '../theme/typographie.dart';
import '../utils/formats.dart';
import '../widgets/communs/boutons.dart';
import '../widgets/communs/etats.dart';
import '../widgets/communs/fond_texture.dart';
import '../widgets/metier/indicateurs.dart';
import '../widgets/metier/negociation.dart';
import 'details_produit.dart';

/// Panier et passage de commande.
///
/// Le prix de chaque ligne suit la quantité : franchir le seuil de vente en
/// gros y bascule le tarif automatiquement, et l'écran le signale afin que le
/// changement ne passe pas pour une erreur.
class Panier extends StatefulWidget {
  const Panier({super.key});

  @override
  State<Panier> createState() => _PanierState();
}

class _PanierState extends State<Panier> {
  final _codePromo = TextEditingController();

  @override
  void dispose() {
    _codePromo.dispose();
    super.dispose();
  }

  void _appliquerCode() {
    final panier = context.read<PanierController>();
    final accepte = panier.appliquerCodePromo(_codePromo.text);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            accepte
                ? 'Code appliqué : ${Formats.prix(panier.remise)} de remise.'
                : 'Ce code promotionnel n\'est pas valide.',
          ),
        ),
      );
  }

  void _commander() {
    final panier = context.read<PanierController>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (contexteFeuille) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Espaces.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Passer la commande', style: Typographie.echelle.titleLarge),
              const SizedBox(height: Espaces.m),
              Text(
                'Le paiement intégré par mobile money, Orange Money, MTN '
                'Money, Wave, est prévu pour une version ultérieure. Dans '
                'cette version, la commande est transmise au vendeur, qui vous '
                'contacte pour convenir du règlement et de la remise.',
                style: Typographie.echelle.bodyMedium,
              ),
              const SizedBox(height: Espaces.l),
              Row(
                children: [
                  Text('Total', style: Typographie.echelle.titleMedium),
                  const Spacer(),
                  Text(
                    Formats.prix(panier.total),
                    style: Typographie.prixCarte,
                  ),
                ],
              ),
              const SizedBox(height: Espaces.l),
              BoutonPrincipal(
                libelle: 'Confirmer la commande',
                onPressed: () {
                  Navigator.of(contexteFeuille).pop();
                  panier.vider();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Commande transmise. Le vendeur va vous contacter.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final panier = context.watch<PanierController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Mon panier (${panier.nombreArticles})'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Symboles.arrowBack),
        ),
        actions: [
          if (!panier.estVide)
            TextButton(
              onPressed: () => _confirmerVidage(panier),
              child: const Text('Vider'),
            ),
        ],
      ),
      body: FondTexture(
        child: panier.estVide
            ? EtatVide(
                icone: Symboles.shoppingCart,
                titre: 'Votre panier est vide',
                message:
                    'Parcourez les annonces près de chez vous et ajoutez ce '
                    'qui vous intéresse.',
                libelleAction: 'Voir les annonces',
                onAction: () => Navigator.of(context).pop(),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        Espaces.l,
                        Espaces.l,
                        Espaces.l,
                        Espaces.xl,
                      ),
                      children: [
                        for (final article in panier.articles)
                          _LigneArticle(
                            article: article,
                            onQuantite: (valeur) => panier.changerQuantite(
                              article.produit.id,
                              valeur,
                            ),
                            onRetirer: () =>
                                panier.retirer(article.produit.id),
                            onOuvrir: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => DetailsProduit(
                                  produit: article.produit,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: Espaces.l),
                        _CodePromo(
                          controleur: _codePromo,
                          codeApplique: panier.codePromo,
                          onAppliquer: _appliquerCode,
                          onRetirer: panier.retirerCodePromo,
                        ),

                        const SizedBox(height: Espaces.xl),
                        _Recapitulatif(panier: panier),
                      ],
                    ),
                  ),
                  _BarreCommande(
                    total: panier.total,
                    onCommander: _commander,
                  ),
                ],
              ),
      ),
    );
  }

  void _confirmerVidage(PanierController panier) {
    showDialog<void>(
      context: context,
      builder: (contexteDialogue) => AlertDialog(
        title: const Text('Vider le panier ?'),
        content: const Text('Tous les articles en seront retirés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexteDialogue).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              panier.vider();
              Navigator.of(contexteDialogue).pop();
            },
            child: Text(
              'Vider',
              style: Typographie.echelle.labelLarge?.copyWith(
                color: Couleurs.erreur,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Une ligne du panier.
class _LigneArticle extends StatelessWidget {
  const _LigneArticle({
    required this.article,
    required this.onQuantite,
    required this.onRetirer,
    required this.onOuvrir,
  });

  final ArticlePanier article;
  final ValueChanged<int> onQuantite;
  final VoidCallback onRetirer;
  final VoidCallback onOuvrir;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Espaces.m),
      child: Container(
        padding: const EdgeInsets.all(Espaces.m),
        decoration: BoxDecoration(
          color: Couleurs.blanc,
          borderRadius: Coupes.carte,
          border: Border.all(color: Couleurs.filet),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onOuvrir,
                  borderRadius: Coupes.puce,
                  child: ClipRRect(
                    borderRadius: Coupes.puce,
                    child: SizedBox(
                      height: 68,
                      width: 68,
                      child: ImageProduit(
                        url: article.produit.photos.isEmpty
                            ? ''
                            : article.produit.photos.first,
                        signature: article.produit.id,
                        hauteurAffichee: 68,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Espaces.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.produit.titre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Typographie.echelle.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        article.produit.nomBoutique,
                        style: Typographie.echelle.bodySmall,
                      ),
                      const SizedBox(height: Espaces.s),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            Formats.prix(article.prixUnitaire),
                            style: Typographie.prixCarte,
                          ),
                          if (article.auTarifGros) ...[
                            const SizedBox(width: Espaces.s),
                            Text(
                              Formats.prix(article.produit.prixDetail),
                              style: Typographie.prixBarre,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRetirer,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Symboles.close,
                    size: 18,
                    color: Couleurs.encrePale,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Espaces.s),
            Row(
              children: [
                if (article.auTarifGros)
                  Expanded(child: _EtiquetteGros(article: article))
                else
                  const Spacer(),
                SelecteurQuantite(
                  quantite: article.quantite,
                  minimum: 0,
                  onChange: onQuantite,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Signale qu'une ligne bénéficie du tarif de gros.
class _EtiquetteGros extends StatelessWidget {
  const _EtiquetteGros({required this.article});

  final ArticlePanier article;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Espaces.s,
        vertical: Espaces.xs,
      ),
      margin: const EdgeInsets.only(right: Espaces.s),
      decoration: BoxDecoration(
        color: Couleurs.orangePale,
        borderRadius: Coupes.badge,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Symboles.inventory2,
            size: 13,
            color: Couleurs.orangeVif,
          ),
          const SizedBox(width: Espaces.xs),
          Flexible(
            child: Text(
              'Tarif de gros appliqué',
              overflow: TextOverflow.ellipsis,
              style: Typographie.echelle.labelSmall?.copyWith(
                color: Couleurs.orangeTexte,
                fontSize: 11,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Saisie du code promotionnel.
class _CodePromo extends StatelessWidget {
  const _CodePromo({
    required this.controleur,
    required this.codeApplique,
    required this.onAppliquer,
    required this.onRetirer,
  });

  final TextEditingController controleur;
  final String codeApplique;
  final VoidCallback onAppliquer;
  final VoidCallback onRetirer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Code promo', style: Typographie.echelle.titleMedium),
        const SizedBox(height: Espaces.s),
        if (codeApplique.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(Espaces.m),
            decoration: BoxDecoration(
              color: Couleurs.orangePale,
              borderRadius: Coupes.puce,
              border: Border.all(color: Couleurs.orange),
            ),
            child: Row(
              children: [
                const Icon(
                  Symboles.localOffer,
                  fill: 1,
                  size: 18,
                  color: Couleurs.orangeVif,
                ),
                const SizedBox(width: Espaces.s),
                Expanded(
                  child: Text(
                    codeApplique,
                    style: Typographie.echelle.titleSmall?.copyWith(
                      color: Couleurs.orangeTexte,
                    ),
                  ),
                ),
                TextButton(onPressed: onRetirer, child: const Text('Retirer')),
              ],
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: Tailles.puce + 10,
                  child: TextField(
                    controller: controleur,
                    textCapitalization: TextCapitalization.characters,
                    style: Typographie.echelle.bodyMedium?.copyWith(
                      color: Couleurs.encre,
                    ),
                    cursorColor: Couleurs.orange,
                    decoration: const InputDecoration(
                      hintText: 'Entrer un code',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: Espaces.l,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Espaces.s),
              BoutonAccentue(
                libelle: 'Appliquer',
                pleineLargeur: false,
                onPressed: onAppliquer,
              ),
            ],
          ),
      ],
    );
  }
}

/// Sous-total, remise, livraison.
class _Recapitulatif extends StatelessWidget {
  const _Recapitulatif({required this.panier});

  final PanierController panier;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Ligne(libelle: 'Sous-total', valeur: Formats.prix(panier.sousTotal)),
        if (panier.remise > 0)
          _Ligne(
            libelle: 'Remise',
            valeur: '− ${Formats.prix(panier.remise)}',
            accentue: true,
          ),
        _Ligne(
          libelle: 'Livraison',
          valeur: panier.livraison == 0
              ? 'Offerte'
              : Formats.prix(panier.livraison),
          accentue: panier.livraison == 0,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: Espaces.m),
          child: Divider(),
        ),
        Row(
          children: [
            Text('Total', style: Typographie.echelle.titleLarge),
            const Spacer(),
            Text(Formats.prix(panier.total), style: Typographie.prix),
          ],
        ),
      ],
    );
  }
}

class _Ligne extends StatelessWidget {
  const _Ligne({
    required this.libelle,
    required this.valeur,
    this.accentue = false,
  });

  final String libelle;
  final String valeur;
  final bool accentue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Espaces.s),
      child: Row(
        children: [
          Text(libelle, style: Typographie.echelle.bodyMedium),
          const Spacer(),
          Text(
            valeur,
            style: Typographie.echelle.titleSmall?.copyWith(
              color: accentue ? Couleurs.orangeVif : Couleurs.encre,
            ),
          ),
        ],
      ),
    );
  }
}

/// Barre basse : total et passage de commande.
class _BarreCommande extends StatelessWidget {
  const _BarreCommande({required this.total, required this.onCommander});

  final double total;
  final VoidCallback onCommander;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(Espaces.l),
        decoration: const BoxDecoration(
          color: Couleurs.blanc,
          boxShadow: Profondeur.barre,
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total', style: Typographie.echelle.bodySmall),
                _MontantAnime(montant: total),
              ],
            ),
            const SizedBox(width: Espaces.l),
            Expanded(
              child: BoutonPrincipal(
                libelle: 'Passer la commande',
                onPressed: onCommander,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Montant qui se renouvelle en glissant, plutôt qu'en se substituant.
///
/// Le total est la seule ligne de l'écran que l'utilisateur surveille pendant
/// qu'il modifie son panier. Remplacé sans transition, le changement peut
/// passer inaperçu, et l'on touche une seconde fois le bouton, croyant avoir
/// manqué son geste. Le chiffre monte donc d'un cran, comme une roue de
/// compteur.
class _MontantAnime extends StatelessWidget {
  const _MontantAnime({required this.montant});

  final double montant;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Mouvement.rapide,
      switchInCurve: Mouvement.courbe,
      transitionBuilder: (enfant, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.4),
            end: Offset.zero,
          ).animate(animation),
          child: enfant,
        ),
      ),
      child: Text(
        Formats.prix(montant),
        key: ValueKey(montant),
        style: Typographie.prixCarte,
      ),
    );
  }
}
