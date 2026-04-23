import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../main.dart';

class ScannerHeader extends StatelessWidget {
  const ScannerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            // Logo Cryptoneo à gauche
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/crypto.png',
                  height: 25,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.shield_rounded, size: 20, color: AppTheme.primary),
                ),
              ),
            ),
            
            // Icône Apple-touch-icon seule (sans cadre ni fond)
            Image.asset(
              'assets/icones/apple-touch-icon.png',
              width: 60, // Légèrement plus grand puisqu'il n'y a plus de cadre
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => 
                const Icon(Icons.apps_rounded, size: 40, color: AppTheme.primary),
            ),

            // Bouton de bascule de thème
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => themeController.toggleTheme(),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          '2D-Doc Authenticator',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Powered by CRYPTONEO',
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
