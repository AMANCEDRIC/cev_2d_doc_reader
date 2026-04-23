import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/app_theme.dart';
import 'screens/splash_welcome_screen.dart';
import 'controllers/theme_controller.dart';

// Instance globale simple pour le thème
final themeController = ThemeController();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const CevApp());
}

class CevApp extends StatelessWidget {
  const CevApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) {
        // Mise à jour de la barre système selon le thème
        final isDark = themeController.isDarkMode;
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ));

        return MaterialApp(
          title: 'CEV 2D-Doc Reader',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          home: const SplashWelcomeScreen(),
        );
      },
    );
  }
}