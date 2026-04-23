import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/doc2d_model.dart';
import '../utils/app_theme.dart';
import '../widgets/result/status_card.dart';
import '../widgets/result/data_card.dart';
import '../widgets/result/info_row.dart';

class ResultScreen extends StatelessWidget {
  final VerificationResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAuthentic = result.isAuthentic;
    final isValid = result.isValid;

    LinearGradient statusGradient;
    IconData statusIcon;
    String statusTitle;
    String statusSubtitle;

    if (isAuthentic) {
      statusGradient = const LinearGradient(
        colors: [Color(0xFF059669), Color(0xFF10B981)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      statusIcon = Icons.verified_user_rounded;
      statusTitle = result.message ?? 'DOCUMENT AUTHENTIQUE';
      statusSubtitle = 'La signature cryptographique a été vérifiée par le serveur.';
    } else if (isValid) {
      statusGradient = const LinearGradient(
        colors: [Color(0xFFD97706), Color(0xFFFBBF24)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      statusIcon = Icons.gpp_maybe_rounded;
      statusTitle = result.message ?? 'SIGNATURE INCORRECTE';
      statusSubtitle = 'Le document peut avoir été falsifié.';
    } else {
      statusGradient = const LinearGradient(
        colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      statusIcon = Icons.gpp_bad_rounded;
      statusTitle = result.message ?? 'ÉCHEC DE VÉRIFICATION';
      statusSubtitle = 'Le serveur n\'a pas pu valider ce document.';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapport d\'Analyse', 
                   style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            StatusCard(
              gradient: statusGradient,
              icon: statusIcon,
              title: statusTitle,
              subtitle: statusSubtitle,
            ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
            
            const SizedBox(height: 24),
            
            if (result.parsedDoc != null) ...[
              _buildSectionTitle('INFORMATIONS GÉNÉRALES', Icons.info_outline_rounded)
                  .animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 12),
              DataCard(children: [
                if (result.reference != null) InfoRow(label: 'Référence', value: result.reference!),
                if (result.typeDocument != null) InfoRow(label: 'Type Doc', value: result.typeDocument!),
                if (result.statut != null) InfoRow(label: 'Statut', value: result.statut!),
                InfoRow(label: 'Émetteur', value: result.parsedDoc!.header.paysEmetteur),
                InfoRow(label: 'Date Émission', value: result.parsedDoc!.header.dateEmission),
              ]).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
              
              const SizedBox(height: 24),
              
              _buildSectionTitle('DONNÉES DÉCODÉES', Icons.article_outlined)
                  .animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 12),
              DataCard(
                children: result.parsedDoc!.fields.map((f) => InfoRow(label: f.label, value: f.value)).toList()
              ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),
            ],

            if (result.error != null) ...[
              const SizedBox(height: 24),
              _buildErrorCard(result.error!),
            ],

            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('NOUVELLE ANALYSE'),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.onSurface,
                  side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
                ),
              ),
            ).animate().fadeIn(delay: 700.ms),
            
            const SizedBox(height: 24),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 35),
                child: Image.asset(
                  'assets/images/crypto.png',
                  height: 25,
                  opacity: const AlwaysStoppedAnimation(0.6),
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildTimestamp(context, result.checkedAt),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppTheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: AppTheme.error, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context, DateTime dt) {
    final dateStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    
    return Text(
      'Analyse effectuée le $dateStr à $timeStr',
      style: TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}