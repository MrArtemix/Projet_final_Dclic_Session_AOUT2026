import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/utilisateur.dart';
import '../services/service_firebase.dart';

/// Cause d'un échec d'authentification, exprimée sans référence à Firebase.
///
/// C'est ce qui permet au contrôleur de rester ignorant du fournisseur
/// d'identité : il reçoit une cause du domaine et choisit le message à
/// afficher, sans jamais manipuler de `FirebaseAuthException`.
enum CauseEchec {
  contactDejaUtilise,
  contactInvalide,
  motDePasseFaible,
  identifiantsIncorrects,
  compteDesactive,
  tropDeTentatives,
  reseauIndisponible,

  /// Le service d'authentification n'accepte pas ce mode de connexion : la
  /// méthode « E-mail/Mot de passe » n'est pas activée côté Firebase. Le
  /// défaut est de configuration, pas de saisie.
  serviceNonConfigure,

  inconnue,
}

/// Échec d'une opération d'authentification.
class EchecAuthentification implements Exception {
  const EchecAuthentification(this.cause);

  final CauseEchec cause;

  @override
  String toString() => 'EchecAuthentification(${cause.name})';
}

/// Accès aux comptes et aux profils.
///
/// Réunit les deux sources qui décrivent un utilisateur : le fournisseur
/// d'identité, qui détient les identifiants de connexion, et la base, qui
/// détient le profil métier, nom, commune, statut de vendeur.
class DepotUtilisateurs {
  const DepotUtilisateurs();

  bool get disponible => ServiceFirebase.disponible;

  /// Identifiant de la session en cours, s'il y en a une.
  String? get identifiantCourant => FirebaseAuth.instance.currentUser?.uid;

  /// Ouvre un compte et renvoie son identifiant.
  ///
  /// Lève [EchecAuthentification] : à l'appelant de traduire la cause.
  Future<String> creerCompte({
    required String contact,
    required String motDePasse,
    required String nom,
  }) async {
    try {
      final identifiants =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: contact.trim(),
        password: motDePasse,
      );
      await identifiants.user!.updateDisplayName(nom.trim());
      return identifiants.user!.uid;
    } on FirebaseAuthException catch (erreur) {
      throw EchecAuthentification(_causeDe(erreur.code));
    } catch (erreur) {
      debugPrint('Création de compte : $erreur');
      throw const EchecAuthentification(CauseEchec.inconnue);
    }
  }

  /// Ouvre une session et renvoie l'identifiant du compte.
  Future<String> connecter({
    required String contact,
    required String motDePasse,
  }) async {
    try {
      final identifiants = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: contact.trim(),
            password: motDePasse,
          );
      return identifiants.user!.uid;
    } on FirebaseAuthException catch (erreur) {
      throw EchecAuthentification(_causeDe(erreur.code));
    } catch (erreur) {
      debugPrint('Connexion : $erreur');
      throw const EchecAuthentification(CauseEchec.inconnue);
    }
  }

  Future<void> deconnecter() async {
    if (!disponible) return;
    await FirebaseAuth.instance.signOut();
  }

  /// Lit le profil métier attaché à un compte.
  ///
  /// Renvoie `null` si le document n'existe pas encore : un compte tout juste
  /// créé peut précéder l'écriture de son profil.
  Future<Utilisateur?> lireProfil(String id) async {
    try {
      final document = await ServiceFirebase.utilisateurs.doc(id).get();
      if (!document.exists) return null;
      return Utilisateur.fromFirestore(document);
    } catch (erreur) {
      debugPrint('Lecture du profil : $erreur');
      return null;
    }
  }

  /// Écrit le profil. [fusionner] conserve les champs absents de l'objet.
  Future<void> enregistrerProfil(
    Utilisateur utilisateur, {
    bool fusionner = false,
  }) async {
    if (!disponible) return;
    await ServiceFirebase.utilisateurs
        .doc(utilisateur.id)
        .set(utilisateur.toMap(), SetOptions(merge: fusionner));
  }

  /// Profil reconstitué depuis le compte, quand la base n'en détient pas
  /// encore.
  Utilisateur? profilDuCompte() {
    final compte = FirebaseAuth.instance.currentUser;
    if (compte == null) return null;
    return _depuisLeCompte(compte);
  }

  /// Profil reconstitué pour un identifiant donné, au retour d'une connexion.
  Utilisateur? profilMinimal(String id) {
    final compte = FirebaseAuth.instance.currentUser;
    if (compte == null || compte.uid != id) return null;
    return _depuisLeCompte(compte);
  }

  Utilisateur _depuisLeCompte(User compte) => Utilisateur(
        id: compte.uid,
        nom: compte.displayName ?? 'Utilisateur',
        contact: compte.email ?? compte.phoneNumber ?? '',
        photo: compte.photoURL ?? '',
      );

  CauseEchec _causeDe(String code) => switch (code) {
        'email-already-in-use' => CauseEchec.contactDejaUtilise,
        'invalid-email' => CauseEchec.contactInvalide,
        'weak-password' => CauseEchec.motDePasseFaible,
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          CauseEchec.identifiantsIncorrects,
        'user-disabled' => CauseEchec.compteDesactive,
        'too-many-requests' => CauseEchec.tropDeTentatives,
        'network-request-failed' => CauseEchec.reseauIndisponible,
        'operation-not-allowed' ||
        'configuration-not-found' =>
          CauseEchec.serviceNonConfigure,
        _ => _inconnue(code),
      };

  /// Un code non répertorié laissait l'utilisateur devant un message
  /// passe-partout et le développeur sans indice : il est au moins consigné.
  CauseEchec _inconnue(String code) {
    debugPrint('Authentification, code non traité : $code');
    return CauseEchec.inconnue;
  }
}
