import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/couleurs.dart';
import '../../theme/dimensions.dart';
import '../../theme/formes.dart';
import '../../theme/profondeur.dart';
import '../../theme/symboles.dart';
import '../../theme/typographie.dart';
import 'boutons.dart';

/// Champ de saisie de l'application.
///
/// Le style provient entièrement du theme : ce widget n'ajoute que la gestion
/// du masquage d'un mot de passe et l'étiquette posée au-dessus du champ,
/// comme sur les écrans d'inscription et de connexion des maquettes.
class ChampTexte extends StatefulWidget {
  const ChampTexte({
    super.key,
    required this.etiquette,
    this.controleur,
    this.indication,
    this.icone,
    this.motDePasse = false,
    this.typeClavier,
    this.validateur,
    this.formateurs,
    this.lignes = 1,
    this.actionClavier,
    this.onChange,
  });

  /// Libellé affiché au-dessus du champ.
  final String etiquette;

  final TextEditingController? controleur;

  /// Texte d'aide affiché dans le champ vide.
  final String? indication;

  final IconData? icone;

  /// Masque la saisie et ajoute l'œil permettant de la révéler.
  final bool motDePasse;

  final TextInputType? typeClavier;
  final String? Function(String?)? validateur;
  final List<TextInputFormatter>? formateurs;
  final int lignes;
  final TextInputAction? actionClavier;
  final ValueChanged<String>? onChange;

  @override
  State<ChampTexte> createState() => _ChampTexteState();
}

class _ChampTexteState extends State<ChampTexte> {
  late bool _masque = widget.motDePasse;

  /// Le champ saisi se signale jusque dans son étiquette : le trait orange du
  /// contour ne suffit pas à désigner, dans un formulaire long, la ligne où
  /// le clavier écrit.
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saisi = _focus.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: Espaces.xs, bottom: Espaces.s),
          child: AnimatedDefaultTextStyle(
            duration: Mouvement.instantane,
            curve: Mouvement.courbe,
            style: Typographie.echelle.labelMedium!.copyWith(
              color: saisi ? Couleurs.orangeTexte : Couleurs.encreDouce,
              fontWeight: saisi ? FontWeight.w600 : FontWeight.w500,
            ),
            child: Text(widget.etiquette),
          ),
        ),
        TextFormField(
          focusNode: _focus,
          controller: widget.controleur,
          obscureText: _masque,
          keyboardType: widget.typeClavier,
          validator: widget.validateur,
          inputFormatters: widget.formateurs,
          maxLines: widget.motDePasse ? 1 : widget.lignes,
          textInputAction: widget.actionClavier,
          onChanged: widget.onChange,
          style: Typographie.echelle.bodyLarge,
          cursorColor: Couleurs.orange,
          decoration: InputDecoration(
            hintText: widget.indication,
            prefixIcon: widget.icone == null
                ? null
                : Icon(
                    widget.icone,
                    size: 20,
                    color: saisi ? Couleurs.orangeTexte : Couleurs.encrePale,
                  ),
            suffixIcon: widget.motDePasse
                ? IconButton(
                    onPressed: () => setState(() => _masque = !_masque),
                    icon: Icon(
                      _masque ? Symboles.visibilityOff : Symboles.visibility,
                      size: 20,
                      color: Couleurs.encrePale,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

/// Barre de recherche de l'accueil et de l'écran de résultats.
///
/// Deux emplois : posée sur l'accueil elle n'est qu'un bouton menant à la
/// recherche ([enLectureSeule] à vrai), tandis que sur l'écran de résultats
/// elle reçoit réellement la saisie.
class BarreRecherche extends StatelessWidget {
  const BarreRecherche({
    super.key,
    this.controleur,
    this.indication = 'Rechercher produits, marques...',
    this.onChange,
    this.onValider,
    this.onTap,
    this.enLectureSeule = false,
    this.autofocus = false,
  });

  final TextEditingController? controleur;
  final String indication;
  final ValueChanged<String>? onChange;
  final ValueChanged<String>? onValider;
  final VoidCallback? onTap;
  final bool enLectureSeule;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const ShapeDecoration(
        shape: StadiumBorder(),
        shadows: Profondeur.contact,
      ),
      child: SizedBox(
        height: Tailles.barreRecherche,
        child: TextField(
          controller: controleur,
          readOnly: enLectureSeule,
          autofocus: autofocus,
          onTap: onTap,
          onChanged: onChange,
          onSubmitted: onValider,
          textInputAction: TextInputAction.search,
          style: Typographie.echelle.bodyMedium?.copyWith(
            color: Couleurs.encre,
          ),
          cursorColor: Couleurs.orange,
          decoration: InputDecoration(
            hintText: indication,
            filled: true,
            fillColor: Couleurs.blanc,
            prefixIcon: const Icon(
              Symboles.search,
              size: 20,
              color: Couleurs.encrePale,
            ),
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: Coupes.pastille,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: Coupes.pastille,
              borderSide: const BorderSide(color: Couleurs.filet),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: Coupes.pastille,
              borderSide: const BorderSide(color: Couleurs.orange, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}

/// Puce de filtre de l'écran de résultats.
///
/// Une puce active passe en orange : c'est un état actif, donc porteur de
/// valeur au sens de la charte. Les filtres restent visibles et modifiables
/// sans réinitialiser la recherche, comme le demande le dossier de conception.
class PuceFiltre extends StatelessWidget {
  const PuceFiltre({
    super.key,
    required this.libelle,
    required this.onTap,
    this.active = false,
    this.avecFleche = true,
  });

  final String libelle;
  final VoidCallback onTap;
  final bool active;

  /// Affiché le chevron indiquant qu'un choix s'ouvre au toucher.
  final bool avecFleche;

  @override
  Widget build(BuildContext context) {
    return Enfoncable(
      child: Material(
        color: active ? Couleurs.orangePale : Couleurs.blanc,
        borderRadius: Coupes.pastille,
        child: InkWell(
          onTap: onTap,
          borderRadius: Coupes.pastille,
          child: Container(
            height: Tailles.puce,
            padding: const EdgeInsets.symmetric(horizontal: Espaces.l),
            decoration: BoxDecoration(
              borderRadius: Coupes.pastille,
              border: Border.all(
                color: active ? Couleurs.orange : Couleurs.filetMarque,
                width: active ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  libelle,
                  style: Typographie.echelle.labelMedium?.copyWith(
                    color: active ? Couleurs.orangeEncre : Couleurs.encre,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (avecFleche) ...[
                  const SizedBox(width: Espaces.xs),
                  Icon(
                    Symboles.keyboardArrowDown,
                    size: 16,
                    color: active ? Couleurs.orangeEncre : Couleurs.encrePale,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
