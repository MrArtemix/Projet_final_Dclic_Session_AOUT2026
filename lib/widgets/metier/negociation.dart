import 'package:flutter/material.dart';

import '../../models/message.dart';
import '../../theme/couleurs.dart';
import '../../theme/dimensions.dart';
import '../../theme/formes.dart';
import '../../theme/profondeur.dart';
import '../../theme/symboles.dart';
import '../../theme/typographie.dart';
import '../../utils/formats.dart';

/// Bulle d'un message texte dans une conversation.
///
/// Les messages de l'utilisateur sont en noir plein et alignés à droite, ceux
/// de l'interlocuteur en blanc creusé et alignés à gauche : la lecture du fil
/// reste immédiate, comme sur les maquettes.
class BulleMessage extends StatelessWidget {
  const BulleMessage({
    super.key,
    required this.message,
    required this.deMoi,
  });

  final Message message;

  /// Vrai lorsque le message a été écrit par l'utilisateur courant.
  final bool deMoi;

  @override
  Widget build(BuildContext context) {
    if (message.type == TypeMessage.systeme) {
      return _MessageSysteme(contenu: message.contenu);
    }

    return Align(
      alignment: deMoi ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Espaces.l,
            vertical: Espaces.m,
          ),
          decoration: BoxDecoration(
            color: deMoi ? Couleurs.noir : Couleurs.blanc,
            // Le coin tourné vers son auteur se resserre : la bulle pointe
            // vers celui qui parle sans qu'il faille lui dessiner une queue.
            borderRadius: Coupes.bulle(emise: deMoi),
            border: deMoi ? null : Border.all(color: Couleurs.filet),
            boxShadow: Profondeur.contact,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.contenu,
                style: Typographie.echelle.bodyLarge?.copyWith(
                  color: deMoi ? Couleurs.blanc : Couleurs.encre,
                ),
              ),
              if (message.horodatage != null) ...[
                const SizedBox(height: Espaces.xs),
                Text(
                  Formats.heure(message.horodatage!),
                  style: Typographie.echelle.labelSmall?.copyWith(
                    fontSize: 10,
                    letterSpacing: 0,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: deMoi
                        ? Couleurs.blanc.withValues(alpha: 0.55)
                        : Couleurs.encrePale,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Message émis par l'application : produit vendu, offre expirée.
class _MessageSysteme extends StatelessWidget {
  const _MessageSysteme({required this.contenu});

  final String contenu;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: Espaces.s),
        padding: const EdgeInsets.symmetric(
          horizontal: Espaces.m,
          vertical: Espaces.s,
        ),
        decoration: BoxDecoration(
          color: Couleurs.blancChamp,
          borderRadius: Coupes.pastille,
        ),
        child: Text(
          contenu,
          textAlign: TextAlign.center,
          style: Typographie.echelle.bodySmall,
        ),
      ),
    );
  }
}

/// Offre de prix affichée dans le fil de négociation.
///
/// Une offre n'est pas un message contenant un montant : c'est un objet à part
/// entière, doté d'un statut, que le destinataire peut accepter, refuser ou
/// contrer. Ce composant porte cette différence à l'écran, encadré orange,
/// montant mis en avant, actions offertes tant que l'offre reste ouverte.
class CarteOffre extends StatelessWidget {
  const CarteOffre({
    super.key,
    required this.message,
    required this.deMoi,
    this.onAccepter,
    this.onRefuser,
    this.onContrer,
  });

  final Message message;
  final bool deMoi;

  /// Actions réservées au destinataire : l'auteur d'une offre ne peut pas
  /// répondre à la sienne.
  final VoidCallback? onAccepter;
  final VoidCallback? onRefuser;
  final VoidCallback? onContrer;

  @override
  Widget build(BuildContext context) {
    final statut = message.statutEffectif;
    final ouverte = statut.estOuverte;
    final peutRepondre = !deMoi && ouverte && onAccepter != null;

    final couleurStatut = switch (statut) {
      StatutOffre.acceptee => Couleurs.succes,
      StatutOffre.refusee => Couleurs.erreur,
      StatutOffre.expiree => Couleurs.encrePale,
      StatutOffre.attente => Couleurs.orange,
    };

    return Align(
      alignment: deMoi ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: Container(
          padding: const EdgeInsets.all(Espaces.l),
          decoration: BoxDecoration(
            gradient: ouverte
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFF9F4), Couleurs.blanc],
                  )
                : null,
            color: ouverte ? null : Couleurs.blancChamp,
            borderRadius: Coupes.champ,
            border: Border.all(
              color: ouverte ? Couleurs.orange : Couleurs.filetMarque,
              width: ouverte ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Symboles.localOffer,
                    size: 16,
                    color: couleurStatut,
                  ),
                  const SizedBox(width: Espaces.s),
                  Text(
                    deMoi ? 'Votre offre' : 'Offre reçue',
                    style: Typographie.echelle.labelSmall?.copyWith(
                      color: couleurStatut,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  if (!ouverte)
                    Text(
                      statut.libelle,
                      style: Typographie.echelle.labelSmall?.copyWith(
                        color: couleurStatut,
                        fontSize: 11,
                        letterSpacing: 0,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Espaces.s),
              Text(
                Formats.prix(message.montantPropose ?? 0),
                style: Typographie.prix.copyWith(
                  color: statut == StatutOffre.expiree
                      ? Couleurs.encrePale
                      : Couleurs.encre,
                ),
              ),
              if (message.contenu.isNotEmpty) ...[
                const SizedBox(height: Espaces.xs),
                Text(message.contenu, style: Typographie.echelle.bodySmall),
              ],
              if (peutRepondre) ...[
                const SizedBox(height: Espaces.m),
                const Divider(),
                const SizedBox(height: Espaces.m),
                Row(
                  children: [
                    Expanded(
                      child: _ActionOffre(
                        libelle: 'Accepter',
                        icone: Symboles.check,
                        couleur: Couleurs.succes,
                        onTap: onAccepter!,
                      ),
                    ),
                    const SizedBox(width: Espaces.s),
                    Expanded(
                      child: _ActionOffre(
                        libelle: 'Contrer',
                        icone: Symboles.swapHoriz,
                        couleur: Couleurs.orange,
                        onTap: onContrer,
                      ),
                    ),
                    const SizedBox(width: Espaces.s),
                    Expanded(
                      child: _ActionOffre(
                        libelle: 'Refuser',
                        icone: Symboles.close,
                        couleur: Couleurs.erreur,
                        onTap: onRefuser,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Une des trois réponses possibles à une offre reçue.
class _ActionOffre extends StatelessWidget {
  const _ActionOffre({
    required this.libelle,
    required this.icone,
    required this.couleur,
    required this.onTap,
  });

  final String libelle;
  final IconData icone;
  final Color couleur;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: couleur.withValues(alpha: 0.08),
      borderRadius: Coupes.puce,
      child: InkWell(
        onTap: onTap,
        borderRadius: Coupes.puce,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Espaces.s + 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 18, color: couleur),
              const SizedBox(height: 2),
              Text(
                libelle,
                style: Typographie.echelle.labelSmall?.copyWith(
                  color: couleur,
                  fontSize: 11,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sélecteur de quantité du panier et de la fiche produit.
///
/// Le bouton d'augmentation porte le noir de l'action ; la diminution reste
/// neutre. Lorsque la quantité franchit le seuil de vente en gros, l'écran
/// appelant en informe l'utilisateur : la règle de bascule des tarifs est
/// portée par le modèle, pas par ce composant.
class SelecteurQuantite extends StatelessWidget {
  const SelecteurQuantite({
    super.key,
    required this.quantite,
    required this.onChange,
    this.minimum = 1,
    this.maximum = 999,
  });

  final int quantite;
  final ValueChanged<int> onChange;
  final int minimum;
  final int maximum;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Pas(
          icone: Symboles.remove,
          actif: quantite > minimum,
          principal: false,
          onTap: () => onChange(quantite - 1),
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 40),
          alignment: Alignment.center,
          child: Text('$quantite', style: Typographie.compteur),
        ),
        _Pas(
          icone: Symboles.add,
          actif: quantite < maximum,
          principal: true,
          onTap: () => onChange(quantite + 1),
        ),
      ],
    );
  }
}

class _Pas extends StatelessWidget {
  const _Pas({
    required this.icone,
    required this.actif,
    required this.principal,
    required this.onTap,
  });

  final IconData icone;
  final bool actif;
  final bool principal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final couleurFond = principal
        ? (actif ? Couleurs.noir : Couleurs.blancCreux)
        : Couleurs.blancChamp;

    return Material(
      color: couleurFond,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: actif ? onTap : null,
        child: SizedBox(
          height: 32,
          width: 32,
          child: Icon(
            icone,
            size: 17,
            color: principal
                ? Couleurs.blanc
                : (actif ? Couleurs.encre : Couleurs.encrePale),
          ),
        ),
      ),
    );
  }
}
