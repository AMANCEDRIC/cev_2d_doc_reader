import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/scanner_controller.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/scanner_viewfinder.dart';
import '../widgets/scanner/scanner_header.dart';
import '../widgets/scanner/scanner_footer.dart';
import 'result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late final ScannerController _controller;
  final TextEditingController _manualController = TextEditingController();
  
  static const String _sample =
      'DC04CI0300012571257115CICI01CJ-2026-CI-00456\x1D02TRAORE\x1D03MAMADOU\x1D0410/03/1988\x1D05BOUAKE\x1D06IVOIRIEN\x1D07NEANT\x1D0830/03/2026\x1D09MME CISSE FATOUMATA\x1FXYCT72O32ADATIVXN3AIWL7T7D2QZKA66O4E3YTXMNBZG4XVIPMT67X4AR34RCZRNQHSXKRYNKJ2LUVHEBQ3D34NTALOAL55XL5YV2Q=';

  @override
  void initState() {
    super.initState();
    _controller = ScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _manualController.dispose();
    super.dispose();
  }

  void _handleProcessing(String raw) async {
    final result = await _controller.processRaw(raw);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            children: [
              _buildBackground(),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  child: Column(
                    children: [
                      const ScannerHeader().animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
                      const SizedBox(height: 32),
                      
                      AnimatedSwitcher(
                        duration: 400.ms,
                        child: _controller.isCameraActive 
                          ? _buildCameraView() 
                          : _buildCameraPlaceholder(),
                      ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 32),
                      _buildActionButtons().animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                      
                      if (_controller.showManual) 
                        _buildManualInput().animate().fadeIn(),
                        
                      const SizedBox(height: 32),
                      const ScannerFooter().animate().fadeIn(delay: 600.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackground() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Positioned.fill(
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(isDark ? 0.05 : 0.1),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 5.seconds),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent.withOpacity(isDark ? 0.05 : 0.1),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1), duration: 7.seconds),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return Column(
      children: [
        Container(
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                MobileScanner(
                  controller: _controller.cameraController,
                  onDetect: (capture) {
                    final barcode = capture.barcodes.firstOrNull;
                    if (barcode?.rawValue != null) {
                      _handleProcessing(barcode!.rawValue!);
                    }
                  },
                ),
                const ScannerViewfinder(),
                if (_controller.isProcessing)
                  GlassContainer(
                    borderRadius: 28,
                    opacity: 0.4,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: AppTheme.primary),
                          const SizedBox(height: 16),
                          const Text(
                            'Analyse en cours...',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: _controller.stopCamera,
          icon: const Icon(Icons.close_rounded),
          label: const Text('ANNULER LE SCAN'),
          style: TextButton.styleFrom(foregroundColor: AppTheme.error),
        ),
      ],
    );
  }

  Widget _buildCameraPlaceholder() {
    return GlassContainer(
      height: 240,
      opacity: 0.05,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner_rounded, 
               size: 64, color: AppTheme.primary.withOpacity(0.5)),
          const SizedBox(height: 20),
          const Text(
            'Prêt pour le scan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Placez le code 2D-Doc dans le cadre',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_controller.isCameraActive) return const SizedBox.shrink();
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: _controller.startCamera,
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('DÉMARRER LE SCANNER'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _controller.toggleManual,
                icon: Icon(_controller.showManual ? Icons.visibility_off_rounded : Icons.keyboard_rounded),
                label: Text(_controller.showManual ? 'FERMER' : 'MANUEL'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextButton.icon(
                onPressed: () => _handleProcessing(_sample),
                icon: const Icon(Icons.play_circle_fill_rounded, color: AppTheme.accent),
                label: const Text('TEST EXEMPLE'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppTheme.accent.withOpacity(0.2)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManualInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Contenu du code 2D-Doc',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              TextButton(
                onPressed: () => _manualController.text = _sample,
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                child: const Text('EXEMPLE', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _manualController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Collez le contenu brut ici...',
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                if (_manualController.text.trim().isNotEmpty) {
                  _handleProcessing(_manualController.text.trim());
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('VALIDER'),
            ),
          ),
        ],
      ),
    );
  }
}