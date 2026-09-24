import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/conversation_controller.dart';
import 'controllers/favoris_controller.dart';
import 'controllers/localisation_controller.dart';
import 'controllers/panier_controller.dart';
import 'controllers/produit_controller.dart';
import 'data/depot_catalogue.dart';
import 'data/depot_conversations.dart';
import 'data/depot_favoris.dart';
import 'data/depot_panier.dart';
import 'data/depot_utilisateurs.dart';
import 'services/service_firebase.dart';
import 'theme/theme_mekano.dart';
import 'views/splash.dart';

/// Point d'entrée de Mekano Afrika.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Formats de date en français : à initialiser avant tout appel à DateFormat.
  await initializeDateFormatting('fr_FR');

  // Firebase démarre si sa configuration est présente ; sinon l'application
  // bascule d'elle-même en mode démonstration, sur le jeu de données local.
  await ServiceFirebase.demarrer();

  // L'interface est conçue pour un usage en portrait, sur téléphone.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ApplicationMekano());
}

/// Racine de l'application.
///
/// Les contrôleurs sont fournis ici, au-dessus de la navigation : ils
/// survivent ainsi aux changements d'écran, ce qui permet à la position
/// choisie et à la session de rester disponibles sur tout le parcours.
///
/// C'est également ici que l'architecture se noue. Les dépôts, seuls à
/// connaître la base, sont construits une fois, puis remis aux contrôleurs
/// qui en ont besoin. Un contrôleur ne va donc jamais chercher sa source de
/// données : il la reçoit. C'est ce qui permet de lui en confier une autre,
/// par exemple un dépôt de remplacement dans un test, sans modifier une seule
/// ligne de sa logique.
class ApplicationMekano extends StatelessWidget {
  const ApplicationMekano({super.key});

  @override
  Widget build(BuildContext context) {
    const depotUtilisateurs = DepotUtilisateurs();
    const depotCatalogue = DepotCatalogue();
    const depotPanier = DepotPanier();
    const depotFavoris = DepotFavoris();
    const depotConversations = DepotConversations();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(depot: depotUtilisateurs),
        ),
        ChangeNotifierProvider(create: (_) => LocalisationController()),
        ChangeNotifierProvider(
          create: (_) => ProduitController(depot: depotCatalogue),
        ),
        ChangeNotifierProvider(
          create: (_) => PanierController(depot: depotPanier),
        ),
        ChangeNotifierProvider(
          create: (_) => FavorisController(depot: depotFavoris),
        ),
        ChangeNotifierProvider(
          create: (_) => ConversationController(depot: depotConversations),
        ),
      ],
      child: MaterialApp(
        title: 'Mekano Afrika',
        debugShowCheckedModeBanner: false,
        theme: ThemeMekano.clair,
        home: const Splash(),
      ),
    );
  }
}
