import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'couleurs.dart';
import 'dimensions.dart';
import 'formes.dart';
import 'profondeur.dart';
import 'typographie.dart';

/// Assemblage du thème Material 3 de l'application.
///
/// Un mot sur la méthode retenue. `ColorScheme.fromSeed` génère une palette
/// harmonisée à partir d'une seule couleur, mais les teintes produites sont
/// pastel : elles contredisent le rendu noir, blanc et orange voulu par le
/// cahier des charges. Le jeu de couleurs est donc déclaré explicitement, rôle
/// par rôle, puis chaque composant du SDK est thémé une fois pour toutes ici.
/// Les écrans n'ont ainsi aucune surcharge de style à porter.
///
/// ## Ce que ce thème ne peut pas porter
///
/// Les ombres de l'application sont composées de deux couches (voir
/// `Profondeur`), quand `ThemeData` n'admet qu'une élévation et une couleur.
/// Les surfaces qui doivent se détacher, cartes, barres, feuilles, posent
/// donc leur ombre elles-mêmes, dans un `BoxDecoration`. Les composants du SDK
/// restent, eux, à élévation nulle : mieux vaut aucune ombre qu'une ombre
/// incohérente avec le reste.
class ThemeMekano {
  const ThemeMekano._();

  /// Jeu de couleurs Material 3, en clair.
  ///
  /// Correspondance avec la charte :
  /// * `primary` porte l'orange, donc la valeur ;
  /// * `secondary` porte le noir, donc l'action principale ;
  /// * les `surface*` forment la pile de blancs, ordonnée du plus clair au
  ///   plus creusé comme le veut Material 3 : une surface s'éclaircit à mesure
  ///   qu'elle s'élève au-dessus du fond.
  ///
  /// Les rôles `*Fixed` sont laissés à leur valeur par défaut : aucun
  /// composant du SDK ne les consulte, et les déclarer donnerait l'illusion
  /// d'un réglage qui ne produit rien.
  static const ColorScheme _jeuDeCouleurs = ColorScheme(
    brightness: Brightness.light,

    primary: Couleurs.orange,
    onPrimary: Couleurs.blanc,
    primaryContainer: Couleurs.orangePale,
    onPrimaryContainer: Couleurs.orangeEncre,

    secondary: Couleurs.noir,
    onSecondary: Couleurs.blanc,
    secondaryContainer: Couleurs.blancChamp,
    onSecondaryContainer: Couleurs.encre,

    tertiary: Couleurs.encreDouce,
    onTertiary: Couleurs.blanc,
    tertiaryContainer: Couleurs.blancCreux,
    onTertiaryContainer: Couleurs.encre,

    error: Couleurs.erreur,
    onError: Couleurs.blanc,
    errorContainer: Couleurs.erreurPale,
    onErrorContainer: Couleurs.erreur,

    surface: Couleurs.fond,
    onSurface: Couleurs.encre,
    onSurfaceVariant: Couleurs.encreDouce,
    surfaceDim: Color(0xFFF2EFEA),
    surfaceBright: Couleurs.blanc,
    surfaceContainerLowest: Couleurs.blanc,
    surfaceContainerLow: Color(0xFFFDFCFA),
    surfaceContainer: Color(0xFFF8F6F3),
    surfaceContainerHigh: Couleurs.blancChamp,
    surfaceContainerHighest: Couleurs.blancCreux,

    outline: Couleurs.filetMarque,
    outlineVariant: Couleurs.filet,
    shadow: Couleurs.ombre,
    scrim: Color(0x66000000),
    inverseSurface: Couleurs.noir,
    onInverseSurface: Couleurs.blanc,
    inversePrimary: Couleurs.orangeClair,
  );

  /// Thème complet de l'application.
  static ThemeData get clair {
    final base = ThemeData(
      colorScheme: _jeuDeCouleurs,
      fontFamily: Typographie.famille,
      scaffoldBackgroundColor: Couleurs.fond,
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      textTheme: Typographie.echelle,

      // Barre d'application : elle prend le ton du fond plutôt que le blanc
      // pur, sans quoi une ligne de démarcation apparaît là où l'écran se met
      // à défiler. Aucune teinte n'est ajoutée au défilement, aucune ombre
      // n'est portée : la charte ne l'autorise pas à cet endroit.
      appBarTheme: const AppBarTheme(
        backgroundColor: Couleurs.fondBarre,
        foregroundColor: Couleurs.encre,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: Typographie.famille,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Couleurs.encre,
        ),
        iconTheme: IconThemeData(color: Couleurs.encre, size: 22),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      // Cartes : blanches, donc plus claires que le fond. C'est cet écart qui
      // les détache, l'ombre ne fait que confirmer. Celles qui doivent porter
      // une ombre composée passent par `Profondeur.contact`.
      cardTheme: const CardThemeData(
        color: Couleurs.blanc,
        surfaceTintColor: Colors.transparent,
        shadowColor: Couleurs.ombre,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: Formes.carte,
      ),

      // Action principale : fond noir, pleine largeur, entièrement arrondie.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Couleurs.noir,
          foregroundColor: Couleurs.blanc,
          disabledBackgroundColor: Couleurs.blancCreux,
          disabledForegroundColor: Couleurs.encrePale,
          minimumSize: const Size.fromHeight(Tailles.bouton),
          elevation: 0,
          textStyle: Typographie.echelle.labelLarge?.copyWith(
            color: Couleurs.blanc,
          ),
          shape: Formes.bouton,
        ),
      ),

      // Action secondaire : contour fin sur fond blanc.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Couleurs.encre,
          backgroundColor: Couleurs.blanc,
          minimumSize: const Size.fromHeight(Tailles.bouton),
          side: const BorderSide(color: Couleurs.filetMarque),
          textStyle: Typographie.echelle.labelLarge,
          shape: Formes.bouton,
        ),
      ),

      // Action de troisième rang : texte seul, dans l'orange assombri, le
      // seul qui tienne le contraste exigé à cette taille de caractère.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Couleurs.orangeTexte,
          textStyle: Typographie.echelle.labelLarge?.copyWith(
            color: Couleurs.orangeTexte,
          ),
          shape: Formes.puce,
        ),
      ),

      // Champs de saisie : un creux dans la surface qui les porte, cerné d'un
      // filet au repos et d'un trait orange une fois saisis.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Couleurs.blancChamp,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Espaces.l,
          vertical: Espaces.l,
        ),
        hintStyle: Typographie.echelle.bodyMedium?.copyWith(
          color: Couleurs.encrePale,
        ),
        labelStyle: Typographie.echelle.bodyMedium,
        floatingLabelStyle: Typographie.echelle.labelMedium?.copyWith(
          color: Couleurs.orangeTexte,
        ),
        errorStyle: Typographie.echelle.bodySmall?.copyWith(
          color: Couleurs.erreur,
        ),
        border: OutlineInputBorder(
          borderRadius: Coupes.champ,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Coupes.champ,
          borderSide: const BorderSide(color: Couleurs.filet),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Coupes.champ,
          borderSide: const BorderSide(color: Couleurs.orange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: Coupes.champ,
          borderSide: const BorderSide(color: Couleurs.erreur),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: Coupes.champ,
          borderSide: const BorderSide(color: Couleurs.erreur, width: 1.5),
        ),
      ),

      // Barre de recherche du SDK, pour la vue à suggestions de l'écran de
      // recherche. Elle est posée à plat : c'est le champ qui appelle, pas son
      // relief.
      searchBarTheme: SearchBarThemeData(
        backgroundColor: const WidgetStatePropertyAll(Couleurs.blancChamp),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        side: const WidgetStatePropertyAll(BorderSide(color: Couleurs.filet)),
        shape: const WidgetStatePropertyAll(Formes.champ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: Espaces.l),
        ),
        hintStyle: WidgetStatePropertyAll(
          Typographie.echelle.bodyMedium?.copyWith(color: Couleurs.encrePale),
        ),
        textStyle: WidgetStatePropertyAll(Typographie.echelle.bodyLarge),
      ),

      searchViewTheme: SearchViewThemeData(
        backgroundColor: Couleurs.blanc,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        dividerColor: Couleurs.filet,
        headerHintStyle: Typographie.echelle.bodyMedium?.copyWith(
          color: Couleurs.encrePale,
        ),
        headerTextStyle: Typographie.echelle.bodyLarge,
        shape: Formes.feuille,
      ),

      // Puces de filtre de l'écran de recherche. Une puce active passe en
      // orange : c'est un état actif, donc porteur de valeur.
      chipTheme: ChipThemeData(
        backgroundColor: Couleurs.blanc,
        selectedColor: Couleurs.orangePale,
        checkmarkColor: Couleurs.orangeEncre,
        side: const BorderSide(color: Couleurs.filetMarque),
        labelStyle: Typographie.echelle.labelMedium!.copyWith(
          color: Couleurs.encre,
        ),
        secondaryLabelStyle: Typographie.echelle.labelMedium!.copyWith(
          color: Couleurs.orangeEncre,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Espaces.m,
          vertical: Espaces.s,
        ),
        shape: const StadiumBorder(),
        showCheckmark: false,
      ),

      // Barre de navigation basse.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Couleurs.blanc,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Couleurs.orangePale,
        indicatorShape: const StadiumBorder(),
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((etats) {
          final actif = etats.contains(WidgetState.selected);
          return Typographie.echelle.labelSmall!.copyWith(
            letterSpacing: 0,
            fontSize: 11,
            color: actif ? Couleurs.orangeTexte : Couleurs.encrePale,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((etats) {
          final actif = etats.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            fill: actif ? 1 : 0,
            color: actif ? Couleurs.orangeTexte : Couleurs.encrePale,
          );
        }),
      ),

      // Onglets de la page boutique : soulignement orange, sans surface pleine.
      tabBarTheme: TabBarThemeData(
        labelColor: Couleurs.encre,
        unselectedLabelColor: Couleurs.encrePale,
        labelStyle: Typographie.echelle.titleSmall,
        unselectedLabelStyle: Typographie.echelle.labelMedium,
        indicatorColor: Couleurs.orange,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Couleurs.filet,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),

      // Feuilles remontantes : filtres, choix d'une option.
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Couleurs.blanc,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: Couleurs.blancCreux,
        shape: Formes.feuilleHaute,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: Couleurs.blanc,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: Typographie.echelle.headlineMedium,
        contentTextStyle: Typographie.echelle.bodyMedium,
        shape: Formes.feuille,
      ),

      menuTheme: const MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(Couleurs.blanc),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          elevation: WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(Formes.carte),
          side: WidgetStatePropertyAll(BorderSide(color: Couleurs.filet)),
        ),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: ShapeDecoration(
          color: Couleurs.noir,
          shape: Formes.puce,
          shadows: Profondeur.flottant,
        ),
        textStyle: Typographie.echelle.labelMedium?.copyWith(
          color: Couleurs.blanc,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Espaces.m,
          vertical: Espaces.s,
        ),
        waitDuration: const Duration(milliseconds: 500),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: Couleurs.noir,
        contentTextStyle: Typographie.echelle.bodyMedium?.copyWith(
          color: Couleurs.blanc,
        ),
        actionTextColor: Couleurs.orangeClair,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: Formes.puce,
      ),

      // L'interrupteur de l'écran compte passe en orange une fois actif.
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Couleurs.blanc),
        trackColor: WidgetStateProperty.resolveWith((etats) {
          return etats.contains(WidgetState.selected)
              ? Couleurs.orange
              : Couleurs.blancCreux;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((etats) {
          return etats.contains(WidgetState.selected)
              ? Couleurs.orange
              : Couleurs.filetMarque;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((etats) {
          return etats.contains(WidgetState.selected)
              ? Couleurs.orange
              : Couleurs.blanc;
        }),
        checkColor: const WidgetStatePropertyAll(Couleurs.blanc),
        side: const BorderSide(color: Couleurs.filetMarque, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),

      dividerTheme: const DividerThemeData(
        color: Couleurs.filet,
        thickness: 1,
        space: 1,
      ),

      iconTheme: const IconThemeData(color: Couleurs.encre, size: 22),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: Espaces.l),
        iconColor: Couleurs.encreDouce,
        shape: Formes.puce,
      ).copyWith(
        titleTextStyle: Typographie.echelle.titleMedium,
        subtitleTextStyle: Typographie.echelle.bodySmall,
      ),

      // Indicateurs de progression dans leur dessin courant : la piste est
      // interrompue devant la tête de lecture, et un point marque la fin de la
      // course.
      //
      // Le drapeau est annoncé déprécié, mais il reste le seul levier : tant
      // qu'il vaut `true`, sa valeur par défaut dans cette version du SDK,
      // le tracé de 2023 est imposé et les réglages d'écart de piste et de
      // point d'arrêt sont ignorés. Il disparaîtra le jour où l'apparence
      // courante deviendra le défaut ; ce réglage sera alors à supprimer.
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        // ignore: deprecated_member_use
        year2023: false,
        color: Couleurs.orange,
        linearTrackColor: Couleurs.blancCreux,
        circularTrackColor: Couleurs.blancCreux,
        stopIndicatorColor: Couleurs.orangePale,
      ),

      // Transition d'écran. Sur Android, le geste de retour prédictif montre
      // l'écran précédent pendant que le doigt tire : hors geste, la même
      // classe retombe sur le fondu glissé de Material 3. Sur iOS, le
      // glissement latéral reste ce que l'utilisateur attend.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
