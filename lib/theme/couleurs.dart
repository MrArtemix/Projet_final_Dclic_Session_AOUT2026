import 'package:flutter/material.dart';

/// Palette de Mekano Afrika.
///
/// Le cahier des charges impose une base noir / blanc / gris relevée d'un
/// accent orange minimal. La règle d'emploi est stricte et se lit sur chaque
/// écran des maquettes :
///
/// * l'orange signale ce qui porte de la valeur : prix, note, distance,
///   réduction, élément actif ;
/// * le noir est réservé à l'action principale : ajouter au panier, passer la
///   commande, suivre la boutique, confirmer une zone ;
/// * le blanc n'est pas une couleur unique mais une pile de teintes très
///   proches, qui crée la profondeur sans recourir aux ombres portées.
///
/// ## Trois règles de lecture
///
/// **L'élévation éclaircit.** Le fond de l'application, [fond], est un blanc
/// très légèrement creusé ; les surfaces qui flottent au-dessus montent vers
/// le [blanc] pur. Une carte se détache alors d'elle-même, sans qu'un trait
/// ait à la cerner. C'est l'inverse de la convention des interfaces sombres,
/// et c'est ce que prescrit Material 3 en clair.
///
/// **Les blancs sont chauds.** Toutes les surfaces partagent une teinte
/// proche de 35°, tenue sous 12 % de saturation. Un blanc parfaitement neutre
/// paraît bleuté à côté de l'orange de la marque ; cette chaleur commune
/// évite la dissonance sans qu'aucune surface ne paraisse colorée.
///
/// **Le texte reste lisible en plein soleil.** Les trois niveaux d'encre
/// dépassent tous le rapport de 4,5:1 exigé par WCAG AA sur le fond de
/// l'application. Le gris clair employé jusqu'ici pour les mentions plafonnait
/// à 2,4:1 : illisible dehors, sur le téléphone d'entrée de gamme que vise le
/// cahier des charges.
///
/// Aucune couleur ne doit être écrite en dur ailleurs dans le projet : toute
/// nuance nécessaire se déclare ici.
class Couleurs {
  const Couleurs._();

  // --- Accent : la valeur ---------------------------------------------------
  // Rampe tonale de l'orange de marque. La teinte ne change pas d'un bout à
  // l'autre : seule la luminance descend, ce qui permet de tenir le contraste
  // sans jamais trahir la couleur de l'enseigne.

  /// Orange de marque. Aplats, icônes, gros chiffres, état actif.
  ///
  /// Sur fond clair, il atteint 3,1:1 : réservé aux surfaces et aux textes de
  /// grande taille. Pour un libellé courant, prendre [orangeTexte].
  static const Color orange = Color(0xFFF26B0F);

  /// Orange soutenu. Aplats forts : badge de réduction, bouton « Appliquer ».
  static const Color orangeVif = Color(0xFFE85D0C);

  /// Orange assombri, seule déclinaison admise pour un texte de petite taille
  /// posé sur une surface claire : 4,6:1, donc conforme AA.
  static const Color orangeTexte = Color(0xFFC4510A);

  /// Orange profond, pour un texte posé sur [orangePale] : 8,5:1.
  static const Color orangeEncre = Color(0xFF7A2E00);

  /// Orange clair, pour un trait ou un état de survol.
  static const Color orangeClair = Color(0xFFFBAE74);

  /// Orange très clair, pour les aplats et halos derrière une zone mise en
  /// avant (image produit, carte, bulle d'offre).
  static const Color orangePale = Color(0xFFFDF0E4);

  // --- Action ---------------------------------------------------------------

  /// Noir des actions principales.
  ///
  /// Légèrement réchauffé : un noir neutre vire au bleu à côté des blancs
  /// chauds de l'application.
  static const Color noir = Color(0xFF121110);

  /// Noir adouci, pour l'état pressé d'une action principale.
  static const Color noirDoux = Color(0xFF26231F);

  // --- Le noir comme surface ------------------------------------------------
  // La charte annonce « noir et orange », mais le noir n'existait jusqu'ici que
  // sur les boutons : l'application entière se lisait comme une suite de blocs
  // blancs sur du blanc, sans masse pour l'ancrer. Les tons qui suivent
  // permettent au noir de porter une surface entière, par exemple l'en-tête
  // d'un écran, sur laquelle le contenu clair vient remonter.

  /// Fond d'un bloc sombre. Plus profond que [noir], qui sert aux boutons : une
  /// grande surface paraît toujours plus claire qu'un petit aplat de même ton.
  static const Color nuit = Color(0xFF0D0C0B);

  /// Haut du dégradé d'un bloc sombre. L'écart avec [nuit] est infime, mais il
  /// suffit à ce que la masse noire ne paraisse pas peinte au rouleau.
  static const Color nuitHaute = Color(0xFF1C1A17);

  /// Surface posée sur un bloc sombre : champ de recherche, puce, vignette.
  static const Color surfaceNuit = Color(0xFF262320);

  /// Texte principal sur fond sombre.
  static const Color encreInverse = Color(0xFFFFFFFF);

  /// Texte secondaire sur fond sombre. Le blanc pur y est trop dur pour une
  /// ligne de détail ; sept dixièmes suffisent et tiennent le contraste.
  static const Color encreInverseDouce = Color(0xB3FFFFFF);

  /// Filet séparant deux surfaces sombres.
  static const Color filetNuit = Color(0x1AFFFFFF);

  // --- Texte ----------------------------------------------------------------
  // Les trois niveaux sont conformes AA sur [fond] : 17,5:1, 5,9:1 et 4,5:1.

  /// Texte principal : titres, prix, libellés d'action.
  static const Color encre = Color(0xFF17171A);

  /// Texte secondaire : descriptions, libellés de champ, métadonnées.
  static const Color encreDouce = Color(0xFF5C616A);

  /// Texte de moindre importance : mentions, indications de saisie.
  static const Color encrePale = Color(0xFF70747B);

  /// Gris décoratif, **jamais pour du texte** : chevron de liste, icône
  /// désactivée, trait d'un graphique.
  static const Color encreFantome = Color(0xFFA8AAB0);

  // --- Surfaces : la pile de blancs -----------------------------------------
  // Du plus lointain au plus proche. Une surface s'éclaircit à mesure qu'elle
  // s'élève : le fond est le seul ton creusé de l'application.

  /// Fond de tous les écrans. Assez creusé pour qu'une carte blanche s'en
  /// détache, assez clair pour rester un blanc.
  static const Color fond = Color(0xFFFBFAF8);

  /// Ton de la barre de titre.
  ///
  /// Quatre niveaux plus sombre que [fond], et ce n'est pas un caprice : la
  /// barre de titre est posée hors du fond texturé, elle ne reçoit donc pas le
  /// grain qui assombrit tout le reste de l'écran d'autant. Sans cette
  /// compensation, une ligne de démarcation apparaît sous la barre.
  static const Color fondBarre = Color(0xFFF8F7F5);

  /// Surface flottante : cartes, barres, feuilles remontantes, dialogues.
  /// Sert aussi d'encre inversée sur les aplats noirs et orange.
  static const Color blanc = Color(0xFFFFFFFF);

  /// Surface des champs de saisie et des puces au repos : un creux dans la
  /// surface qui la porte.
  ///
  /// L'écart avec le fond doit rester lisible en plein jour : à moins de huit
  /// niveaux de gris, un champ vide cesse de se voir comme une zone à remplir.
  static const Color blancChamp = Color(0xFFF1EEE8);

  /// Surface des zones inactives et des images en attente de chargement.
  static const Color blancCreux = Color(0xFFEBE7E1);

  // --- Traits et ombres -----------------------------------------------------

  /// Filet d'un pixel entre deux surfaces.
  ///
  /// Opaque, et non plus un noir translucide : superposé à un fond teinté, un
  /// noir dilué grisaille la couleur qu'il traverse.
  static const Color filet = Color(0xFFE9E5DF);

  /// Filet plus marqué, pour les séparateurs de section et les contours
  /// d'actions secondaires.
  static const Color filetMarque = Color(0xFFD9D3CA);

  /// Teinte des ombres portées.
  ///
  /// Brun très foncé plutôt que noir : une ombre noire sur un blanc chaud
  /// paraît sale. Les opacités d'emploi sont fixées par `Profondeur`.
  static const Color ombre = Color(0xFF140E08);

  // --- États ----------------------------------------------------------------
  // Assombris par rapport aux teintes vives d'usage courant, pour rester
  // lisibles en texte de petite taille sur fond clair.

  /// Succès : vendeur en ligne, offre acceptée, badge vérifié.
  static const Color succes = Color(0xFF15803D);

  /// Erreur : champ invalide, offre refusée, annonce signalée.
  static const Color erreur = Color(0xFFC81E1E);

  /// Information neutre : message système dans une conversation.
  static const Color info = Color(0xFF2563EB);

  /// Fond d'un message d'erreur.
  static const Color erreurPale = Color(0xFFFDECEC);

  // --- États d'un produit ---------------------------------------------------
  // Le dossier de conception demande que neuf, occasion et bradé se
  // distinguent visuellement sur chaque annonce.

  /// Produit neuf.
  static const Color etatNeuf = succes;

  /// Produit d'occasion ou reconditionné.
  static const Color etatOccasion = info;

  /// Produit bradé.
  static const Color etatBrade = orangeVif;
}
