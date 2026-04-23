import 'package:flutter/material.dart';

class ScannerFooter extends StatelessWidget {
  const ScannerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Padding(
            // On ajoute un décalage à gauche pour compenser l'espace vide à droite du logo
            padding: const EdgeInsets.only(left: 35), 
            child: Image.asset(
              'assets/images/crypto.png',
              height: 25,
              fit: BoxFit.contain,
              opacity: const AlwaysStoppedAnimation(0.6),
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBadge(theme, 'SECURE'),
            _buildBadge(theme, 'VERIFIED'),
            _buildBadge(theme, 'PRO'),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(ThemeData theme, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.03),
        border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.08)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),
      ),
    );
  }
}
