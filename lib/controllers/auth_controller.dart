import 'package:flutter/foundation.dart';

import '../data/depot_utilisateurs.dart';
import '../models/utilisateur.dart';

/// Authentification et profil de l'utilisateur courant.
///
/// Deux principes gouvernent ce contrôleur.
///
/// D'abord, **le statut informel ne bloque rien**. Un vendeur qui se déclare
/// informel accède exactement aux mêmes fonctions qu'une boutique enregistrée :
/// aucun document n'est exigé, aucune vérification ne conditionne l'accès.
/// C'est l'exigence la plus structurante du cahier des charges.
///
/// Ensuite, l'application doit rester démontrable sans Firebase. Lorsque le
/// service est indisponible, le contrôleur bascule sur un compte local de
/// démonstration plutôt que d'interrompre le parcours.
class AuthController extends ChangeNotifier {
  AuthController({DepotUtilisateurs depot = const DepotUtilisateurs()})
      : _depot = depot;

  /// Accès aux données, reçu à la construction : ni le fournisseur d'identité
  /// ni la base ne sont nommés dans ce contrôleur.
  final DepotUtilisateurs _depot;

  Utilisateur? _utilisateur;
  bool _enCours = false;
  String _erreur = '';

  /// Utilisateur connecté, ou `null`.
  Utilisateur? get utilisateur => _utilisateur;

  bool get estConnecte => _utilisateur != null;
  bool get enCours => _enCours;

  /// Dernier message d'erreur, à afficher sous le formulaire.
  String get erreur => _erreur;

  /// Restaure la session au démarrage de l'application.
  Future<void> restaurerSession() async {
    if (!_depot.disponible) return;

    final identifiant = _depot.identifiantCourant;
    if (identifiant == null) return;

    _utilisateur =
        await _depot.lireProfil(identifiant) ?? _depot.profilDuCompte();
    notifyListeners();
  }

  /// Crée un compte.
  ///
  /// [statutVendeur] est déclaratif : il est enregistré tel quel, sans
  /// justificatif ni contrôle, y compris pour un vendeur informel.
  Future<bool> creerCompte({
    required String nom,
    required String contact,
    required String motDePasse,
    TypeCompte typeCompte = TypeCompte.particulier,
    StatutVendeur statutVendeur = StatutVendeur.aucun,
    String commune = '',
  }) async {
    _demarrer();

    if (!_depot.disponible) {
      _utilisateur = _compteDemonstration(
        nom: nom,
        contact: contact,
        typeCompte: typeCompte,
        statutVendeur: statutVendeur,
        commune: commune,
      );
      _terminer();
      return true;
    }

    try {
      final identifiant = await _depot.creerCompte(
        contact: contact,
        motDePasse: motDePasse,
        nom: nom,
      );

      final profil = Utilisateur(
        id: identifiant,
        nom: nom.trim(),
        contact: contact.trim(),
        typeCompte: typeCompte,
        statutVendeur: statutVendeur,
        commune: commune,
        dateCreation: DateTime.now(),
      );

      await _depot.enregistrerProfil(profil);

      _utilisateur = profil;
      _terminer();
      return true;
    } on EchecAuthentification catch (echec) {
      _echouer(_messagePour(echec.cause));
      return false;
    } catch (erreur) {
      _echouer('Création du compte impossible. Réessayez.');
      debugPrint('Création de compte : $erreur');
      return false;
    }
  }

  /// Connecte un utilisateur existant.
  Future<bool> seConnecter({
    required String contact,
    required String motDePasse,
  }) async {
    _demarrer();

    if (!_depot.disponible) {
      _utilisateur = _compteDemonstration(
        nom: 'Jean Kouassi',
        contact: contact,
      );
      _terminer();
      return true;
    }

    try {
      final identifiant = await _depot.connecter(
        contact: contact,
        motDePasse: motDePasse,
      );

      _utilisateur = await _depot.lireProfil(identifiant) ??
          _depot.profilMinimal(identifiant);
      _terminer();
      return true;
    } on EchecAuthentification catch (echec) {
      _echouer(_messagePour(echec.cause));
      return false;
    } catch (erreur) {
      _echouer('Connexion impossible. Vérifiez votre réseau.');
      debugPrint('Connexion : $erreur');
      return false;
    }
  }

  /// Ouvre une session de démonstration, sans identifiants.
  ///
  /// Sert à parcourir l'application lors d'une présentation, et à poursuivre
  /// le parcours lorsque Firebase est injoignable.
  void ouvrirSessionDemonstration() {
    _utilisateur = _compteDemonstration(
      nom: 'Jean Kouassi',
      contact: '+225 07 00 00 00 00',
    );
    notifyListeners();
  }

  Future<void> seDeconnecter() async {
    await _depot.deconnecter();
    _utilisateur = null;
    notifyListeners();
  }

  /// Met à jour le profil, y compris le passage d'acheteur à vendeur.
  ///
  /// Le dossier de conception demande que ce changement de rôle se fasse sans
  /// créer un second compte : c'est exactement ce que fait cette méthode.
  Future<void> mettreAJourProfil({
    String? nom,
    TypeCompte? typeCompte,
    StatutVendeur? statutVendeur,
    String? commune,
    double? latitude,
    double? longitude,
  }) async {
    final actuel = _utilisateur;
    if (actuel == null) return;

    _utilisateur = actuel.copieAvec(
      nom: nom,
      typeCompte: typeCompte,
      statutVendeur: statutVendeur,
      commune: commune,
      latitude: latitude,
      longitude: longitude,
    );
    notifyListeners();

    await _depot.enregistrerProfil(_utilisateur!, fusionner: true);
  }

  /// Enregistre la position courante sur le profil.
  Future<void> memoriserPosition({
    required double latitude,
    required double longitude,
    required String commune,
  }) =>
      mettreAJourProfil(
        latitude: latitude,
        longitude: longitude,
        commune: commune,
      );

  // --- Interne --------------------------------------------------------------

  Utilisateur _compteDemonstration({
    required String nom,
    required String contact,
    TypeCompte typeCompte = TypeCompte.particulier,
    StatutVendeur statutVendeur = StatutVendeur.aucun,
    String commune = 'Cocody',
  }) =>
      Utilisateur(
        id: 'demonstration',
        nom: nom.trim().isEmpty ? 'Utilisateur' : nom.trim(),
        contact: contact.trim(),
        typeCompte: typeCompte,
        statutVendeur: statutVendeur,
        commune: commune,
        verifie: true,
        note: 4.8,
        nbCommandes: 12,
        dateCreation: DateTime.now(),
      );

  /// Traduction d'une cause d'échec en message affichable.
  String _messagePour(CauseEchec cause) => switch (cause) {
        CauseEchec.contactDejaUtilise => 'Cette adresse est déjà utilisée.',
        CauseEchec.contactInvalide => 'Adresse électronique invalide.',
        CauseEchec.motDePasseFaible =>
          'Mot de passe trop court : six caractères au minimum.',
        CauseEchec.identifiantsIncorrects =>
          'Identifiant ou mot de passe incorrect.',
        CauseEchec.compteDesactive => 'Ce compte a été désactivé.',
        CauseEchec.tropDeTentatives =>
          'Trop de tentatives. Réessayez dans un moment.',
        CauseEchec.reseauIndisponible =>
          'Réseau indisponible. Vérifiez votre connexion.',
        CauseEchec.serviceNonConfigure =>
          'Connexion par e-mail non activée sur le serveur.',
        CauseEchec.inconnue => 'Opération impossible pour le moment.',
      };

  void _demarrer() {
    _enCours = true;
    _erreur = '';
    notifyListeners();
  }

  void _terminer() {
    _enCours = false;
    _erreur = '';
    notifyListeners();
  }

  void _echouer(String message) {
    _enCours = false;
    _erreur = message;
    notifyListeners();
  }
}
