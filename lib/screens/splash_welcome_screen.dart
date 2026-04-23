import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/app_theme.dart';
import 'scanner_screen.dart';

class SplashWelcomeScreen extends StatefulWidget {
  const SplashWelcomeScreen({super.key});

  @override
  State<SplashWelcomeScreen> createState() => _SplashWelcomeScreenState();
}

class _SplashWelcomeScreenState extends State<SplashWelcomeScreen> {
  static const String _slogan = 'Le gage de la confiance numérique';
  static const double _logoLeftCompensation = 50;
  Timer? _sloganTimer;
  Timer? _navigationTimer;
  bool _showSlogan = false;

  @override
  void initState() {
    super.initState();

    _sloganTimer = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      setState(() => _showSlogan = true);
    });

    _navigationTimer = Timer(const Duration(milliseconds: 4200), _goToScanner);
  }

  @override
  void dispose() {
    _sloganTimer?.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _goToScanner() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(isDark),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 36),
                    _buildSlogan(theme),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Positioned.fill(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -90,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: isDark ? 0.08 : 0.14),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.18, 1.18),
                    duration: 5.seconds,
                  ),
            ),
            Positioned(
              bottom: -90,
              left: -90,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent.withValues(alpha: isDark ? 0.08 : 0.14),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
                    begin: const Offset(1.15, 1.15),
                    end: const Offset(1, 1),
                    duration: 6.seconds,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final logoCore = Center(
      child: Padding(
        // Meme compensation que le footer scanner/resultat.
        padding: const EdgeInsets.only(left: _logoLeftCompensation),
        child: Image.asset(
          'assets/images/crypto.png',
          height: 72,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.verified_user_rounded, size: 64, color: Colors.white);
          },
        ),
      ),
    ).animate().fadeIn(duration: 650.ms).scale(
          duration: 850.ms,
          curve: Curves.easeOutBack,
          begin: const Offset(0.7, 0.7),
          end: const Offset(1, 1),
        );

    return logoCore
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .moveY(
          begin: 0,
          end: -7,
          duration: 1800.ms,
          curve: Curves.easeInOutSine,
        );
  }

  Widget _buildSlogan(ThemeData theme) {
    if (!_showSlogan) {
      return const SizedBox(height: 30);
    }

    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: _slogan.length),
      duration: const Duration(milliseconds: 1700),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        final text = _slogan.substring(0, value);
        return Text(
          text,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        );
      },
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.18, end: 0);
  }
}
