import '../models/boutique.dart';
import '../models/categorie.dart';
import '../models/produit.dart';
import 'communes.dart';

/// Jeu de données de démonstration.
///
/// Il sert à deux choses : peupler Cloud Firestore au premier lancement, et
/// permettre de parcourir l'application sans connexion réseau. Les annonces
/// sont réparties sur les communes d'Abidjan avec des prix, des états et des
/// formes d'échange variés, afin que les filtres, le tri par proximité et la
/// bascule entre tarif de détail et tarif de gros puissent réellement être
/// éprouvés.
class JeuDemonstration {
  const JeuDemonstration._();

  static const List<Categorie> categories = [
    Categorie(id: 'cat_ordinateur', nom: 'Ordinateurs', nomIcone: 'ordinateur'),
    Categorie(id: 'cat_telephone', nom: 'Téléphonie', nomIcone: 'telephone'),
    Categorie(id: 'cat_composant', nom: 'Composants', nomIcone: 'composant'),
    Categorie(id: 'cat_audio', nom: 'Audio', nomIcone: 'audio'),
    Categorie(id: 'cat_reseau', nom: 'Réseau', nomIcone: 'reseau'),
    Categorie(id: 'cat_accessoire', nom: 'Accessoires', nomIcone: 'accessoire'),
  ];

  static final List<Boutique> boutiques = [
    Boutique(
      id: 'b_digismart',
      logo: 'assets/images/logo_magasins/digi_smart.png',
      idProprietaire: 'v_kone',
      nom: 'DIGI SMART Boutique',
      categorie: 'Informatique',
      description:
          'Boutique spécialisée dans la vente de matériel informatique neuf '
          'et reconditionné. Livraison rapide et service après-vente garanti '
          'dans toute la commune de Cocody.',
      telephone: '+225 07 00 00 00 00',
      adresse: 'Cocody, Abidjan, Côte d\'Ivoire',
      commune: 'Cocody',
      latitude: 5.3600,
      longitude: -3.9800,
      note: 4.8,
      nbAvis: 256,
      nbProduits: 128,
      nbAbonnes: 1200,
      nbVentes: 3400,
      verifiee: true,
      tauxReponse: 94,
    ),
    Boutique(
      id: 'b_techplus',
      logo: 'assets/images/logo_magasins/tech_plus.png',
      idProprietaire: 'v_diallo',
      nom: 'Tech Plus Abidjan',
      categorie: 'Téléphonie et accessoires',
      description:
          'Téléphones neufs et d\'occasion, accessoires et réparation. '
          'Tarifs dégressifs pour les commandes en gros.',
      telephone: '+225 05 00 00 00 00',
      adresse: 'Adjamé, Abidjan',
      commune: 'Adjamé',
      latitude: 5.3547,
      longitude: -4.0244,
      note: 4.5,
      nbAvis: 142,
      nbProduits: 86,
      nbAbonnes: 840,
      nbVentes: 1900,
      verifiee: true,
      tauxReponse: 88,
    ),
    Boutique(
      id: 'b_oraimo',
      logo: 'assets/images/logo_magasins/oraimo.png',
      idProprietaire: 'v_yao',
      nom: 'oraimo Store Abidjan',
      categorie: 'Accessoires et charge',
      description:
          'Point de vente agréé oraimo : écouteurs, batteries externes, '
          'chargeurs rapides et montres connectées. Tous les articles sont '
          'garantis douze mois, échange sous quinze jours en boutique.',
      telephone: '+225 07 47 00 00 00',
      adresse: 'Boulevard du Gabon, Marcory, Abidjan',
      commune: 'Marcory',
      latitude: 5.3000,
      longitude: -3.9833,
      note: 4.6,
      nbAvis: 312,
      nbProduits: 74,
      nbAbonnes: 2450,
      nbVentes: 5200,
      verifiee: true,
      tauxReponse: 92,
    ),
    Boutique(
      id: 'b_bose',
      logo: 'assets/images/logo_magasins/bose.png',
      idProprietaire: 'v_bamba',
      nom: 'Bose Store Abidjan',
      categorie: 'Audio haut de gamme',
      description:
          'Revendeur officiel Bose en Côte d\'Ivoire. Casques à réduction de '
          'bruit, enceintes portables et barres de son, présentés en cabine '
          'd\'écoute. Garantie constructeur deux ans.',
      telephone: '+225 27 20 30 00 00',
      adresse: 'Avenue Chardy, Plateau, Abidjan',
      commune: 'Plateau',
      latitude: 5.3253,
      longitude: -4.0227,
      note: 4.9,
      nbAvis: 96,
      nbProduits: 28,
      nbAbonnes: 1380,
      nbVentes: 740,
      verifiee: true,
      tauxReponse: 97,
    ),
    Boutique(
      id: 'b_ivoiretech',
      logo: 'assets/images/logo_magasins/ivoire_tech_market.png',
      idProprietaire: 'v_traore',
      nom: 'Ivoire Tech Market',
      categorie: 'Généraliste',
      description:
          'Magasin généraliste : ordinateurs, écrans, imprimantes, onduleurs '
          'et pièces détachées, en neuf comme en reconditionné. Devis pour '
          'les entreprises et les écoles, livraison dans tout Abidjan.',
      telephone: '+225 05 05 00 00 00',
      adresse: 'Avenue 16, Treichville, Abidjan',
      commune: 'Treichville',
      latitude: 5.2939,
      longitude: -4.0086,
      note: 4.4,
      nbAvis: 208,
      nbProduits: 340,
      nbAbonnes: 1120,
      nbVentes: 2800,
      verifiee: true,
      tauxReponse: 85,
    ),
  ];

  /// Treize annonces réparties sur les cinq boutiques.
  ///
  /// Chacune porte ses photographies. Les annonces sans visuel ont été
  /// retirées du jeu : faute d'image, elles retombaient sur le motif de
  /// réseau, et une liste de motifs ne démontre rien.
  static final List<Produit> produits = [
    _annonce(
      id: 'p_elitebook',
      photos: [
        'assets/images/photos_produit/ordinateur/01_hero_open.jpg',
        'assets/images/photos_produit/ordinateur/02_closed_angle.jpg',
        'assets/images/photos_produit/ordinateur/03_keyboard_detail.jpg',
        'assets/images/photos_produit/ordinateur/04_package_product.jpg',
        'assets/images/photos_produit/ordinateur/05_exploded_view.jpg',
        'assets/images/photos_produit/ordinateur/06_accessories_desk.jpg',
        'assets/images/photos_produit/ordinateur/07_accessories_travel.jpg',
        'assets/images/photos_produit/ordinateur/08_in_use_ad.jpg',
      ],
      boutique: boutiques[0],
      categorie: 'cat_ordinateur',
      titre: 'Ordinateur portable HP EliteBook 840',
      description:
          'Ordinateur portable performant, idéal pour la bureautique et le '
          'multitâche. Écran 14 pouces Full HD, processeur Intel Core i5, '
          '8 Go de RAM, 256 Go SSD. Livré avec chargeur d\'origine et '
          'garantie 6 mois.',
      prix: 45000,
      prixAvant: 60000,
      etat: EtatProduit.occasion,
      note: 4.5,
      nbAvis: 128,
      prixGros: 38000,
      seuilGros: 10,
      caracteristiques: {
        'Marque': 'HP',
        'Modèle': 'EliteBook 840',
        'État': 'Reconditionné',
        'Garantie': '6 mois',
      },
    ),




    _annonce(
      id: 'p_freepods',
      photos: [
        'assets/images/photos_produit/casque_oraimo/oraimo_boompop_n_01_hero.jpg',
        'assets/images/photos_produit/casque_oraimo/oraimo_boompop_n_03_rear.jpg',
        'assets/images/photos_produit/casque_oraimo/oraimo_boompop_n_04_folded.jpg',
        'assets/images/photos_produit/casque_oraimo/oraimo_boompop_n_05_box.jpg',
        'assets/images/photos_produit/casque_oraimo/oraimo_boompop_n_06_contents.jpg',
        'assets/images/photos_produit/casque_oraimo/oraimo_boompop_n_07_accessories.jpg',
        'assets/images/photos_produit/casque_oraimo/oraimo_boompop_n_08_lifestyle.jpg',
      ],
      boutique: boutiques[2],
      categorie: 'cat_audio',
      titre: 'oraimo BoomPop 2',
      description:
          'Casque sans fil à réduction de bruit active, autonomie de '
          'cinquante heures. Coussinets à mémoire de forme, pliable, étui '
          'de transport fourni. Scellé, garantie douze mois en boutique.',
      prix: 22000,
      prixAvant: 27000,
      etat: EtatProduit.neuf,
      note: 4.5,
      nbAvis: 87,
      prixGros: 18000,
      seuilGros: 10,
      caracteristiques: {
        'Marque': 'oraimo',
        'Modèle': 'BoomPop 2',
        'Autonomie': '50 heures',
        'Réduction de bruit': 'Active',
        'Garantie': '12 mois',
      },
    ),
    _annonce(
      id: 'p_qc45',
      photos: [
        'assets/images/photos_produit/casque_bose/bose_qc_ultra_01_hero.jpg',
        'assets/images/photos_produit/casque_bose/bose_qc_ultra_02_side.jpg',
        'assets/images/photos_produit/casque_bose/bose_qc_ultra_03_rear.jpg',
        'assets/images/photos_produit/casque_bose/bose_qc_ultra_04_folded.jpg',
        'assets/images/photos_produit/casque_bose/bose_qc_ultra_05_box.jpg',
        'assets/images/photos_produit/casque_bose/bose_qc_ultra_06_contents.jpg',
        'assets/images/photos_produit/casque_bose/bose_qc_ultra_07_accessories.jpg',
        'assets/images/photos_produit/casque_bose/bose_qc_ultra_08_lifestyle.jpg',
      ],
      boutique: boutiques[3],
      categorie: 'cat_audio',
      titre: 'Bose QuietComfort Ultra',
      description:
          'Casque circum-auriculaire à réduction de bruit, référence de sa '
          'catégorie. Vingt-quatre heures d\'autonomie, deux modes d\'écoute, '
          'étui de transport rigide. Neuf, sous garantie constructeur.',
      prix: 285000,
      prixAvant: 320000,
      etat: EtatProduit.neuf,
      note: 4.9,
      nbAvis: 38,
      caracteristiques: {
        'Marque': 'Bose',
        'Modèle': 'QuietComfort Ultra',
        'Autonomie': '24 heures',
        'Réduction de bruit': 'Active, deux modes',
        'Garantie': '24 mois constructeur',
      },
    ),
    _annonce(
      id: 'p_pc_bureau',
      photos: [
        'assets/images/photos_produit/pc_desktop/01_hero_front.jpg',
        'assets/images/photos_produit/pc_desktop/02_rear_angle.jpg',
        'assets/images/photos_produit/pc_desktop/03_side_detail.jpg',
        'assets/images/photos_produit/pc_desktop/04_package_product.jpg',
        'assets/images/photos_produit/pc_desktop/05_exploded_view.jpg',
        'assets/images/photos_produit/pc_desktop/06_accessories_keyboard_mouse.jpg',
        'assets/images/photos_produit/pc_desktop/07_accessories_headset_controller.jpg',
        'assets/images/photos_produit/pc_desktop/08_in_use_ad.jpg',
      ],
      boutique: boutiques[0],
      categorie: 'cat_ordinateur',
      titre: 'PC de bureau assemblé Core i5',
      description:
          'Unité centrale assemblée en boutique : Intel Core i5, 16 Go de '
          'mémoire, SSD de 512 Go. Montée et testée sur place, garantie '
          'un an pièces et main-d\'œuvre.',
      prix: 320000,
      etat: EtatProduit.neuf,
      note: 4.6,
      nbAvis: 34,
      caracteristiques: {
        'Processeur': 'Intel Core i5',
        'Mémoire': '16 Go',
        'Stockage': 'SSD 512 Go',
        'Garantie': '12 mois',
      },
    ),
    _annonce(
      id: 'p_arduino',
      photos: [
        'assets/images/photos_produit/arduino/01_vue_principale.jpg',
        'assets/images/photos_produit/arduino/02_vue_carte.jpg',
        'assets/images/photos_produit/arduino/03_contenu_kit.jpg',
        'assets/images/photos_produit/arduino/04_vue_composants.jpg',
        'assets/images/photos_produit/arduino/05_vue_rapprochee.jpg',
        'assets/images/photos_produit/arduino/06_kit_carton.jpg',
        'assets/images/photos_produit/arduino/07_accessoires.jpg',
        'assets/images/photos_produit/arduino/08_projet_utilisation.jpg',
      ],
      boutique: boutiques[0],
      categorie: 'cat_composant',
      titre: 'Kit de démarrage Arduino',
      description:
          'Kit complet pour débuter en électronique programmable : carte '
          'compatible Uno, capteurs, afficheur, câbles et platine '
          'd\'essai. Livret d\'exercices en français.',
      prix: 25000,
      prixAvant: 32000,
      etat: EtatProduit.neuf,
      note: 4.5,
      nbAvis: 76,
      prixGros: 20000,
      seuilGros: 10,
      caracteristiques: {
        'Carte': 'Compatible Uno',
        'Capteurs': 'Plus de 20',
        'Niveau': 'Débutant',
        'Documentation': 'Français',
      },
    ),
    _annonce(
      id: 'p_kit_electronique',
      photos: [
        'assets/images/photos_produit/kits_electroniques/01_vue_principale.jpg',
        'assets/images/photos_produit/kits_electroniques/02_vue_trois_quarts.jpg',
        'assets/images/photos_produit/kits_electroniques/04_vue_de_dessus.jpg',
        'assets/images/photos_produit/kits_electroniques/05_decomposition_complete.jpg',
        'assets/images/photos_produit/kits_electroniques/06_accessoires_essentiels.jpg',
        'assets/images/photos_produit/kits_electroniques/07_accessoires_composition_deux.jpg',
        'assets/images/photos_produit/kits_electroniques/08_publicite_utilisation.jpg',
      ],
      boutique: boutiques[0],
      categorie: 'cat_composant',
      titre: 'Kit de composants électroniques',
      description:
          'Assortiment de résistances, condensateurs, diodes, transistors '
          'et circuits intégrés, rangés par valeur dans un coffret à '
          'compartiments. Pour atelier ou formation.',
      prix: 18000,
      etat: EtatProduit.neuf,
      note: 4.3,
      nbAvis: 41,
      prixGros: 14000,
      seuilGros: 15,
      caracteristiques: {
        'Références': 'Plus de 300',
        'Rangement': 'Coffret compartimenté',
        'Usage': 'Atelier, formation',
      },
    ),
    _annonce(
      id: 'p_tablette',
      photos: [
        'assets/images/photos_produit/tablette/01_vue_principale.jpg',
        'assets/images/photos_produit/tablette/02_vue_trois_quarts.jpg',
        'assets/images/photos_produit/tablette/03_vue_arriere_connectique.jpg',
        'assets/images/photos_produit/tablette/04_vue_de_dessus.jpg',
        'assets/images/photos_produit/tablette/05_decomposition_complete.jpg',
        'assets/images/photos_produit/tablette/06_accessoires_essentiels.jpg',
        'assets/images/photos_produit/tablette/07_accessoires_composition_deux.jpg',
        'assets/images/photos_produit/tablette/08_publicite_utilisation.jpg',
      ],
      boutique: boutiques[1],
      categorie: 'cat_telephone',
      titre: 'Tablette 11 pouces 128 Go',
      description:
          'Tablette Android à écran de onze pouces, 128 Go de stockage, '
          'quatre haut-parleurs. Livrée avec housse et chargeur rapide. '
          'Convient à l\'étude comme au dessin.',
      prix: 165000,
      prixAvant: 195000,
      etat: EtatProduit.neuf,
      note: 4.4,
      nbAvis: 58,
      prixGros: 145000,
      seuilGros: 5,
      caracteristiques: {
        'Écran': '11 pouces',
        'Stockage': '128 Go',
        'Accessoires': 'Housse et chargeur',
        'Garantie': '12 mois',
      },
    ),
    _annonce(
      id: 'p_drone',
      photos: [
        'assets/images/photos_produit/drone/dji-drone-gallery-hero.jpg',
        'assets/images/photos_produit/drone/dji-drone-gallery-ad-in-use.jpg',
        'assets/images/photos_produit/drone/dji-drone-gallery-bottom.jpg',
        'assets/images/photos_produit/drone/dji-drone-gallery-box-product.jpg',
        'assets/images/photos_produit/drone/dji-drone-gallery-exploded-isometric.jpg',
        'assets/images/photos_produit/drone/dji-drone-gallery-side.jpg',
        'assets/images/photos_produit/drone/dji-drone-gallery-accessories-1.jpg',
        'assets/images/photos_produit/drone/dji-drone-gallery-accessories-2.jpg',
        'assets/images/photos_produit/drone/dji-drone-gallery-lifestyle.jpg',
      ],
      boutique: boutiques[4],
      categorie: 'cat_accessoire',
      titre: 'Drone caméra 4K avec accessoires',
      description:
          'Drone pliable à caméra 4K stabilisée, trois batteries, hélices '
          'de rechange et sacoche de transport. Pour la prise de vue '
          'aérienne et le repérage de chantier.',
      prix: 420000,
      prixAvant: 480000,
      etat: EtatProduit.neuf,
      note: 4.7,
      nbAvis: 23,
      caracteristiques: {
        'Caméra': '4K stabilisée',
        'Batteries': '3 fournies',
        'Transport': 'Sacoche rigide',
        'Garantie': '12 mois',
      },
    ),
    _annonce(
      id: 'p_camera',
      photos: [
        'assets/images/photos_produit/camera/01_vue_principale.jpg',
        'assets/images/photos_produit/camera/02_vue_trois_quarts.jpg',
        'assets/images/photos_produit/camera/03_vue_arriere_connectique.jpg',
        'assets/images/photos_produit/camera/04_vue_de_dessus.jpg',
        'assets/images/photos_produit/camera/05_decomposition_complete.jpg',
        'assets/images/photos_produit/camera/06_accessoires_essentiels.jpg',
        'assets/images/photos_produit/camera/07_accessoires_composition_deux.jpg',
        'assets/images/photos_produit/camera/08_publicite_utilisation.jpg',
      ],
      boutique: boutiques[4],
      categorie: 'cat_accessoire',
      titre: 'Caméra de surveillance Wi-Fi',
      description:
          'Caméra de surveillance intérieure, vision nocturne, détection '
          'de mouvement et alerte sur téléphone. Enregistrement sur carte '
          'mémoire ou dans le nuage.',
      prix: 45000,
      etat: EtatProduit.neuf,
      note: 4.2,
      nbAvis: 94,
      prixGros: 36000,
      seuilGros: 10,
      caracteristiques: {
        'Résolution': '2K',
        'Vision nocturne': 'Oui',
        'Stockage': 'Carte mémoire ou nuage',
        'Alimentation': 'Secteur',
      },
    ),
    _annonce(
      id: 'p_robot',
      photos: [
        'assets/images/photos_produit/robots/robot_humanoid_kit_01_hero.jpg',
        'assets/images/photos_produit/robots/robot_humanoid_kit_02_side.jpg',
        'assets/images/photos_produit/robots/robot_humanoid_kit_03_rear.jpg',
        'assets/images/photos_produit/robots/robot_humanoid_kit_04_pose.jpg',
        'assets/images/photos_produit/robots/robot_humanoid_kit_05_box.jpg',
        'assets/images/photos_produit/robots/robot_humanoid_kit_06_contents.jpg',
        'assets/images/photos_produit/robots/robot_humanoid_kit_07_accessories.jpg',
        'assets/images/photos_produit/robots/robot_humanoid_kit_08_lifestyle.jpg',
      ],
      boutique: boutiques[4],
      categorie: 'cat_composant',
      titre: 'Kit robot humanoïde programmable',
      description:
          'Robot humanoïde à assembler et programmer, dix-sept '
          'servomoteurs, application de pilotage. Destiné aux clubs de '
          'robotique et aux établissements scolaires.',
      prix: 285000,
      etat: EtatProduit.neuf,
      note: 4.6,
      nbAvis: 17,
      caracteristiques: {
        'Servomoteurs': '17',
        'Programmation': 'Application dédiée',
        'Public': 'Clubs et écoles',
        'Montage': 'À assembler',
      },
    ),
    _annonce(
      id: 'p_imprimante3d',
      photos: [
        'assets/images/photos_produit/imprimante_3d/01_vue_principale.jpg',
        'assets/images/photos_produit/imprimante_3d/02_vue_frontale.jpg',
        'assets/images/photos_produit/imprimante_3d/04_vue_plongeante.jpg',
        'assets/images/photos_produit/imprimante_3d/05_vue_eclatee.jpg',
        'assets/images/photos_produit/imprimante_3d/06_produit_carton.jpg',
        'assets/images/photos_produit/imprimante_3d/07_accessoires.jpg',
        'assets/images/photos_produit/imprimante_3d/08_utilisation_pub.jpg',
      ],
      boutique: boutiques[4],
      categorie: 'cat_accessoire',
      titre: 'Imprimante 3D à filament',
      description:
          'Imprimante 3D à dépôt de filament, volume de 220 sur 220 sur '
          '250 millimètres, plateau chauffant. Livrée montée, calibrée et '
          'accompagnée d\'une bobine d\'essai.',
      prix: 245000,
      prixAvant: 290000,
      etat: EtatProduit.neuf,
      note: 4.5,
      nbAvis: 31,
      caracteristiques: {
        'Volume': '220 × 220 × 250 mm',
        'Plateau': 'Chauffant',
        'Livraison': 'Montée et calibrée',
        'Filament': 'Bobine fournie',
      },
    ),
    _annonce(
      id: 'p_kit_reseau',
      photos: [
        'assets/images/photos_produit/kits_reseau/01_vue_principale.jpg',
        'assets/images/photos_produit/kits_reseau/02_outil_sertissage.jpg',
        'assets/images/photos_produit/kits_reseau/03_contenu_kit.jpg',
        'assets/images/photos_produit/kits_reseau/04_vue_eclatee.jpg',
        'assets/images/photos_produit/kits_reseau/05_connecteurs_cables.jpg',
        'assets/images/photos_produit/kits_reseau/06_kit_carton.jpg',
        'assets/images/photos_produit/kits_reseau/07_accessoires.jpg',
        'assets/images/photos_produit/kits_reseau/08_installation_pub.jpg',
      ],
      boutique: boutiques[4],
      categorie: 'cat_reseau',
      titre: 'Kit de sertissage réseau complet',
      description:
          'Coffret d\'installation réseau : pince à sertir, testeur de '
          'continuité, dénudeur, connecteurs RJ45 et câble. De quoi '
          'câbler un bureau entier.',
      prix: 38000,
      etat: EtatProduit.neuf,
      note: 4.4,
      nbAvis: 52,
      prixGros: 30000,
      seuilGros: 8,
      caracteristiques: {
        'Pince': 'Sertissage RJ45',
        'Testeur': 'Continuité',
        'Connecteurs': '100 fournis',
        'Câble': 'Bobine 30 m',
      },
    ),
    _annonce(
      id: 'p_routeur',
      photos: [
        'assets/images/photos_produit/microtik/01_vue_principale.jpg',
        'assets/images/photos_produit/microtik/02_vue_routeur.jpg',
        'assets/images/photos_produit/microtik/03_vue_equipements.jpg',
        'assets/images/photos_produit/microtik/04_vue_eclatee.jpg',
        'assets/images/photos_produit/microtik/05_ports_connectique.jpg',
        'assets/images/photos_produit/microtik/06_kit_carton.jpg',
        'assets/images/photos_produit/microtik/07_accessoires.jpg',
        'assets/images/photos_produit/microtik/08_installation_pub.jpg',
      ],
      boutique: boutiques[4],
      categorie: 'cat_reseau',
      titre: 'Routeur MikroTik hAP ax²',
      description: 'Routeur neuf, quatre ports Gigabit, configuration incluse.',
      prix: 55000,
      etat: EtatProduit.neuf,
      note: 4.6,
      nbAvis: 19,
    ),

  ];

  /// Fabrique une annonce en reprenant la position et l'identité de sa
  /// boutique : sur le terrain, l'annonce est publiée là où se trouve le
  /// vendeur.
  static Produit _annonce({
    required String id,
    required Boutique boutique,
    required String categorie,
    required String titre,
    required String description,
    required double prix,
    required EtatProduit etat,
    double? prixAvant,
    double? prixGros,
    int? seuilGros,
    TypeTransaction transaction = TypeTransaction.vente,
    double note = 0,
    int nbAvis = 0,
    Map<String, String> caracteristiques = const {},
    List<String> photos = const [],
  }) {
    return Produit(
      id: id,
      idVendeur: boutique.idProprietaire,
      idBoutique: boutique.id,
      nomBoutique: boutique.nom,
      idCategorie: categorie,
      titre: titre,
      description: description,
      photos: photos,
      prixDetail: prix,
      prixAvant: prixAvant,
      prixGros: prixGros,
      seuilGros: seuilGros,
      etat: etat,
      typeTransaction: transaction,
      caracteristiques: caracteristiques,
      latitude: boutique.latitude,
      longitude: boutique.longitude,
      commune: boutique.commune,
      note: note,
      nbAvis: nbAvis,
      datePublication: DateTime(2026, 9, 1),
    );
  }

  /// Position de référence utilisée par la démonstration tant que l'utilisateur
  /// n'a ni autorisé la localisation ni choisi de commune.
  static const Commune positionParDefaut = Communes.parDefaut;
}
